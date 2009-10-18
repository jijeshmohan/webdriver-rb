require "webdriver/error"
require "webdriver/point"
require "webdriver/target_locator"
require "webdriver/navigation"
require "webdriver/options"
require "webdriver/find"
require "webdriver/driver"
require "webdriver/element"


module WebDriver
  autoload :IE,     'webdriver/ie'
  autoload :Remote, 'webdriver/remote'
end

