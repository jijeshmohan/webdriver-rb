require "webdriver/error"
require "webdriver/target_locator"
require "webdriver/navigation"
require "webdriver/options"
require "webdriver/find"
require "webdriver/driver"
require "webdriver/element"


module WebDriver
  Point     = Struct.new(:x, :y)
  Dimension = Struct.new(:width, :heigth)

  autoload :IE,     'webdriver/ie'
  autoload :Remote, 'webdriver/remote'
  autoload :Chrome, 'webdriver/chrome'
end

