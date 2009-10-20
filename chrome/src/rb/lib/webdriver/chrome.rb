require "webdriver/chrome/launcher"
require "webdriver/chrome/bridge"
require "webdriver/chrome/command_executor"

require "socket"
require "json"
require "thread"

Thread.abort_on_exception = true
$stdout.sync = true