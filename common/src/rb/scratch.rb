require "rubygems"
require "lib/webdriver"
require "pp"

100.times do
  ie = WebDriver::Driver.new(:ie)
  ie.get "google.com"
  ie.elements_by_tag_name('div')
  ie.quit
  GC.start

  count = {:elements => 0, :drivers => 0, :pointers => 0}

  ObjectSpace.each_object(WebDriver::Element) { |obj| count[:elements] += 1 }
  ObjectSpace.each_object(WebDriver::Driver) { |obj| count[:drivers] += 1 }
  ObjectSpace.each_object(FFI::Pointer) { |obj| count[:pointers] += 1 }

  pp count
end