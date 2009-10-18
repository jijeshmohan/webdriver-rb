require "webdriver/error"
require "webdriver/point"
require "webdriver/target_locator"
require "webdriver/navigation"
require "webdriver/options"
require "webdriver/find"
require "webdriver/common_driver"
require "webdriver/common_element"


module WebDriver
  autoload :IE,     'webdriver/ie'
  autoload :Remote, 'webdriver/remote'
end

