require "spec"
require "webdriver"
require "webdriver/spec_support"

if WebDriver::Platform.jruby?
  require "java"
  Dir["common/lib/buildtime/*.jar", "build/*.jar"].each { |jar| require jar }
  GlobalTestEnv = WebDriver::SpecSupport::JRubyTestEnvironment.new
else
  GlobalTestEnv = WebDriver::SpecSupport::TestEnvironment.new
end

Spec::Runner.configure do |c|
  c.include(WebDriver::SpecSupport::Helpers)
end

class Object
  include WebDriver::SpecSupport::Guards
end

at_exit { GlobalTestEnv.quit }

$stdout.sync = true
