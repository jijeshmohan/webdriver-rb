require "spec"
require "webdriver"
require "ostruct"

TEST_URL = "file://" + File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "web"))

Page = OpenStruct.new(
  :drag_and_drop => "#{TEST_URL}/dragAndDropTest.html",
  :form          => "#{TEST_URL}/formPage.html",
  :iframe        => "#{TEST_URL}/iframes.html",
  :javascript    => "#{TEST_URL}/javascriptPage.html",
  :nested        => "#{TEST_URL}/nestedElements.html",
  :xhtml         => "#{TEST_URL}/xhtmlTest.html"
)

# hack to find out what driver we're using
if $LOAD_PATH.any? { |p| p.include?("remote/client") }
  $__webdriver__ = :remote
elsif $LOAD_PATH.any? { |p| p.include?("jobbie") }
  $__webdriver__ = :ie
else
  abort "not sure what driver to run specs for"
end

def fix_windows_path(path)
  return path unless $__webdriver__ == :ie
  path = path[%r[file://(.*)], 1]
  path.gsub!("/", '\\')

  "file://#{path}"
end

def driver
  $driver ||= case $__webdriver__
              when :remote
                WebDriver::Driver.new :remote, :server_url           => "http://localhost:8080/",
                                               :desired_capabilities => WebDriver::Remote::Capabilities.firefox
              when :ie
                WebDriver::Driver.new :ie
              end
end

at_exit { driver.quit rescue nil }

