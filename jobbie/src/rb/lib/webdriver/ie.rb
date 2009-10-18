
module WebDriver
  module IE
    DLL = "#{File.dirname(__FILE__)}/../../../../prebuilt/Win32/Release/InternetExplorerDriver.dll" 
  end
end

require "ffi"

require "webdriver/ie/lib"
require "webdriver/ie/util"
require "webdriver/ie/error"
require "webdriver/ie/bridge"
