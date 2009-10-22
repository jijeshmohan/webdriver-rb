require "spec"
require "ostruct"
require "pp"

require "webdriver"

TEST_URL = "file://" + File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "web"))

Page = OpenStruct.new(
  :drag_and_drop => "#{TEST_URL}/dragAndDropTest.html",
  :form          => "#{TEST_URL}/formPage.html",
  :iframe        => "#{TEST_URL}/iframes.html",
  :javascript    => "#{TEST_URL}/javascriptPage.html",
  :nested        => "#{TEST_URL}/nestedElements.html",
  :xhtml         => "#{TEST_URL}/xhtmlTest.html"
)

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
                    abort "not sure what driver to run specs for"
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
  end

  module Helpers
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
  end

  module Guards
    def not_compliant_on(opts = {}, &blk)
      yield unless opts.all? { |key, value| WebDriver::SpecHelper.send(key) == value}
    end
    alias_method :deviates_on, :not_compliant_on
  end

end


def driver
  $driver ||= case WebDriver::SpecHelper.driver
              when :remote
                WebDriver::Driver.remote :server_url           => "http://localhost:8080/",
                                         :desired_capabilities => WebDriver::Remote::Capabilities.send(ENV['REMOTE_BROWSER_VERSION'] || 'firefox')
              when :ie
                WebDriver::Driver.ie
              when :chrome
                WebDriver::Driver.chrome
              end
end

at_exit { driver.quit rescue nil }
$stdout.sync = true

Spec::Runner.configure do |c|
  c.include(WebDriver::SpecHelper::Helpers)
end

class Object
  include WebDriver::SpecHelper::Guards
end