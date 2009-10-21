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

# hack to find out what driver we're using
if $LOAD_PATH.any? { |p| p.include?("remote/client") }
  $__webdriver__ = :remote
elsif $LOAD_PATH.any? { |p| p.include?("jobbie") }
  $__webdriver__ = :ie
elsif $LOAD_PATH.any? { |p| p.include?("chrome") }
  $__webdriver__ = :chrome
else
  abort "not sure what driver to run specs for"
end

# TODO: fix this mess
def fix_windows_path(path)
  return path unless WebDriver::Platform.os == :windows
  if $__webdriver__ == :ie
    path = path[%r[file://(.*)], 1]
    path.gsub!("/", '\\')

    "file://#{path}"
  else
    path.sub(%r[file:/{0,2}], "file:///")
  end
end

def driver
  $driver ||= case $__webdriver__
              when :remote
                browser_version = ENV['REMOTE_BROWSER_VERSION'] || 'firefox'
                WebDriver::Driver.new :remote, :server_url           => "http://localhost:8080/",
                                               :desired_capabilities => WebDriver::Remote::Capabilities.send(browser_version)
              when :ie
                WebDriver::Driver.new :ie
              when :chrome
                WebDriver::Driver.new :chrome
              end
end

at_exit { driver.quit rescue nil }

$stdout.sync = true # FIXME