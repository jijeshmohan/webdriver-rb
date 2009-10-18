require "#{File.dirname(__FILE__)}/spec_helper"

describe "WebDriver::TargetLocator" do
  it "should switch to a frame" do
    driver.navigate.to Page.iframe
    driver.switch_to.frame("iframe1")
  end

  it "should switch to a window" do
    driver.navigate.to Page.xhtml
    
    driver.find_element(:link, "Open new window").click
    driver.title.should == "XHTML Test Page"
    
    driver.switch_to.window("result")
    driver.title.should == "We Arrive Here"
  end

  it "should find active element" do
    driver.navigate.to Page.xhtml
    # FIXME: shared Element class
    # driver.switch_to.active_element.should be_an_instance_of(WebDriver::Remote::Element)
    driver.switch_to.active_element.class.name.should =~ /Element$/
  end

end

