require 'goliath/proxy/connection'
module Goliath
  module Proxy
    class Server < ::Goliath::Server
      # Starts the server running. This will execute the reactor, load config and plugins and
      # start listening for requests
      #
      # @return Does not return until the server has halted.
      def start(&blk)
        EM.epoll
        EM.synchrony do
          trap("INT")  { stop }
          trap("TERM") { stop }

          if RUBY_PLATFORM !~ /mswin|mingw/
            trap("HUP")  { load_config(options[:config]) }
          end

          load_config(options[:config])
          load_plugins

          EM.set_effective_user(options[:user]) if options[:user]

          config[Goliath::Constants::GOLIATH_SIGNATURE] = EM.start_server(address, port, Goliath::Proxy::Connection) do |conn|
            if options[:ssl]
              conn.start_tls(
                  :private_key_file => options[:ssl_key],
                  :cert_chain_file  => options[:ssl_cert],
                  :verify_peer      => options[:ssl_verify]
              )
            end

            conn.port = port
            conn.app = app
            conn.api = api
            conn.logger = logger
            conn.status = status
            conn.config = config
            conn.options = options
          end

          blk.call(self) if blk
        end
      end


    end
  end
end