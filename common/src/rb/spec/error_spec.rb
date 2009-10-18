require "#{File.dirname(__FILE__)}/spec_helper"

describe "Error" do

  it "should have an appropriate message" do
    driver.navigate.to Page.xhtml
    
    lambda { driver.find_element(:id, "nonexistant") }.should raise_error(
        WebDriver::Error::NoSuchElementException, /Unable to find element/
    )
  end

  it "should show stack trace information"
end