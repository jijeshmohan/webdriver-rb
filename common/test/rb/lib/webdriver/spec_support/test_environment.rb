module WebDriver
  module SpecSupport
    class TestEnvironment

      attr_accessor :unguarded

      def driver
        # TODO: find a better way to do this
        @driver ||= if $LOAD_PATH.any? { |p| p.include?("remote/client") }
                      :remote
                    elsif $LOAD_PATH.any? { |p| p.include?("jobbie") }
                      :ie
                    elsif $LOAD_PATH.any? { |p| p.include?("chrome") }
                      :chrome
                    else
                      raise "not sure what driver to run specs for"
                    end
      end

      def browser
        if driver == :remote
          # TODO: get rid of ENV
          (ENV['REMOTE_BROWSER_VERSION'] || :firefox).to_sym
        else
          driver
        end
      end

      def driver_instance
          @driver_instance ||= begin
            case driver
            when :remote
              remote_server.start
              cap = WebDriver::Remote::Capabilities.send(ENV['REMOTE_BROWSER_VERSION'] || 'firefox')
              WebDriver::Driver.remote :server_url           => "http://localhost:6000/",
                                       :desired_capabilities => cap
            when :ie
              WebDriver::Driver.ie
            when :chrome
              WebDriver::Driver.chrome
            end
          end
      end

      def app_server
        raise NotImplementedError, "need a simple rack app to serve static files from common/web/"
      end

      def remote_server
        raise NotImplementedError, "no remote server impl. on MRI yet"
      end

      def quit
        driver_instance.quit
        app_server.stop
        remote_server.stop if driver == :remote

        @driver_instance = @app_server = @remote_server = nil
      end

      def unguarded?
        @unguarded ||= false
      end

      def url_for(filename)
        app_server.where_is filename
      end

    end # TestEnvironment
  end # SpecSupport
end # WebDriver