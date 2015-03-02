require 'goliath/proxy/constants'
module Goliath
  module Proxy
    class Connection < ::Goliath::Connection
      include Constants
      # This is intentionally completely overriden from the superclass's
      # version as it is required to re use the listeners on the parser
      # for a second time around if an SSL address is being proxied
      def post_init
        @current = nil
        @requests = []
        @pending  = []
        @parser = Http::Parser.new(self)
      end
      def on_headers_complete(h)
        self.restarting = false
        if @parser.http_method == 'CONNECT'
          restart_with_ssl(@parser.request_url, h)
        else

          env = Goliath::Env.new
          env[SERVER_PORT] = port.to_s
          env[RACK_LOGGER] = logger
          env[OPTIONS]     = options
          env[STATUS]      = status
          env[CONFIG]      = config
          env[REMOTE_ADDR] = remote_address
          add_original_headers(env) if @ssl

          r = Goliath::Request.new(@app, self, env)
          r.parse_header(h, @parser) do
            env[ASYNC_HEADERS] = api.method(:on_headers) if api.respond_to?(:on_headers)
            env[ASYNC_BODY]    = api.method(:on_body)    if api.respond_to?(:on_body)
            env[ASYNC_CLOSE]   = api.method(:on_close)   if api.respond_to?(:on_close)
          end
          modify_headers_for_ssl(env) if @ssl
          @requests.push(r)

        end
      end

      def restart_with_ssl(url, headers)
        @ssl = url
        self.restarting = true
        @parser.reset!  ##Prevent any further parsing of this as it is the CONNECT request which we dont do anything else with
        @parser = Http::Parser.new(self)
        @original_headers = headers.clone
        send_data("HTTP/1.0 200 Connection established\r\nProxy-agent: goliath-proxy/0.0.0\r\n\r\n")
        start_tls(
            private_key_file: File.expand_path('../../../../mitm.key', __FILE__),
            cert_chain_file: File.expand_path('../../../../mitm.crt', __FILE__)
        )
      end

      def on_body(data)
        @requests.first.parse(data)
      end
      def on_message_complete
        self.restarting = false
        req = @requests.shift

        if @current.nil?
          @current = req
          @current.succeed
        else
          @pending.push(req)
        end

        req.process if !@parser.upgrade? && !req.env[:terminate_connection]

      end

      # Deliberately overriding this from the superclass as  we want to prevent
      # everything after parsing of the data IF this is restarting
      def receive_data(data)
        begin
          @parser << data
          return if restarting
          if @parser.upgrade?
            if !@current.env[UPGRADE_DATA]
              @current.env[UPGRADE_DATA] = @parser.upgrade_data
              @current.process
            else
              @current.parse(data)
            end
          end

        rescue HTTP::Parser::Error => e
          terminate_request(false)
        end
      end

      private
      attr_accessor :restarting

      def add_original_headers(env)
        @original_headers.each do |name, value|
          converted_name = "HTTP_#{name.gsub(/-/, '_').upcase}"
          env[converted_name] = value
        end

      end

      def modify_headers_for_ssl(env)
        uri = URI.parse(@parser.request_url)
        url = "https://#{@ssl}#{[uri.path, uri.query].compact.join('?')}"
        env['REQUEST_URI'] = url
        env['HTTPS'] = 'on'
      end

    end
  end
end