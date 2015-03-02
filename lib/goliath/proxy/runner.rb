require 'goliath/proxy'
module Goliath
  module Proxy
    class Runner < ::Goliath::Runner
      # Sets up the Goliath server
      #
      # @param log [Logger] The logger to configure the server to log to
      # @return [Server] an instance of a Goliath Proxy server
      def setup_server(log = setup_logger)
        server = Goliath::Proxy::Server.new(@address, @port)
        server.logger = log
        server.app = @app
        server.api = @api
        server.plugins = @plugins || []
        server.options = @server_options
        server
      end


    end
  end
end