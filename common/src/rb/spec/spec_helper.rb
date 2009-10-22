require "spec"
require "ostruct"
require "pp"

require "webdriver"

if WebDriver::Platform.jruby?
  require "java"
  require 'build/webdriver-common-test.jar'
  Dir["common/lib/buildtime/*.jar", "build/*.jar"].each { |jar| require jar }
end

module WebDriver::SpecHelper
  class << self
    def driver
      # messy
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
        (ENV['REMOTE_BROWSER_VERSION'] || :firefox).to_sym
      else
        driver
      end
    end

    attr_accessor :unguarded

    def unguarded?
      @unguarded ||= false
    end

    def remote_server
      @remote_server ||= begin
        puts "starting remote server"

        Dir['remote/common/lib/**/*.jar'].each { |j| require j }

        context = org.mortbay.jetty.servlet.Context.new
        context.setContextPath("/")
        context.addServlet("org.openqa.selenium.remote.server.DriverServlet", "/*")

        server  = org.mortbay.jetty.Server.new(8080)
        server.setHandler context

        server
      end
    end
  end

  module Helpers
    def environment
      @@environment ||= begin
        if WebDriver::Platform.jruby?
          puts "creating InProcessTestEnvironment"
          org.openqa.selenium.environment.InProcessTestEnvironment.new
        else
          # WebDriver::Support::TestEnvironment.new TODO: ruby server for specs?
        end
      end
    end

    def app_server
      @app_server ||= environment.getAppServer
    end

    def url_for(filename)
      app_server.whereIs filename
    end

    def fix_windows_path(path)
      return path unless WebDriver::Platform.os == :windows

      if SpecHelper.browser == :ie
        path = path[%r[file://(.*)], 1]
        path.gsub!("/", '\\')

        "file://#{path}"
      else
        path.sub(%r[file:/{0,2}], "file:///")
      end
    end

    def driver
      $driver ||= case WebDriver::SpecHelper.driver
                  when :remote
                    # TODO: clean up remote server startup
                    raise "needs jruby to run remote server atm" unless WebDriver::Platform.jruby?

                    WebDriver::SpecHelper.remote_server.start
                    sleep 2
                    cap = WebDriver::Remote::Capabilities.send(ENV['REMOTE_BROWSER_VERSION'] || 'firefox')
                    WebDriver::Driver.remote :server_url           => "http://localhost:8080/",
                                             :desired_capabilities => cap
                  when :ie
                    WebDriver::Driver.ie
                  when :chrome
                    WebDriver::Driver.chrome
                  end
    end
  end

  module Guards
    def not_compliant_on(opts = {}, &blk)
      yield unless opts.all? { |key, value| WebDriver::SpecHelper.send(key) == value}
    end
    alias_method :deviates_on, :not_compliant_on
  end

end


Spec::Runner.configure do |c|
  c.include(WebDriver::SpecHelper::Helpers)
end

class Object
  include WebDriver::SpecHelper::Guards
end

at_exit do
  if WebDriver::SpecHelper.driver == :remote
    WebDriver::SpecHelper.remote_server.stop
  end
  driver.quit rescue nil
end
$stdout.sync = true
