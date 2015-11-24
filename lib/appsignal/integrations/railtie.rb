Appsignal.logger.info("Loading Rails (#{Rails.version}) integration")

require 'appsignal/rack/rails_instrumentation'

module Appsignal
  module Integrations
    class Railtie < ::Rails::Railtie
      initializer 'appsignal.configure_rails_initialization' do |app|
        Appsignal::Integrations::Railtie.initialize_appsignal(app)
      end

      #config.after_initialize do
      #  Appsignal::Hooks.load_hooks
      #end

      def self.initialize_appsignal(app)
        # Load config
        Appsignal.config = Appsignal::Config.new(
          Rails.root,
          ENV.fetch('APPSIGNAL_APP_ENV', Rails.env),
          :name => Rails.application.class.parent_name,
          :log_file_path => Rails.root.join('log/appsignal.log')
        )

        # Start logger
        Appsignal.start_logger

        app.middleware.insert_before(
          ActionDispatch::RemoteIp,
          Appsignal::Rack::RailsInstrumentation
        )

        if Appsignal.config.active? &&
          Appsignal.config[:enable_frontend_error_catching] == true
          app.middleware.insert_before(
            Appsignal::Rack::RailsInstrumentation,
            Appsignal::Rack::JSExceptionCatcher,
          )
        end

        Appsignal.start
      end
    end
  end
end