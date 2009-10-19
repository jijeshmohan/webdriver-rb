require "#{File.dirname(__FILE__)}/spec_helper"

describe "Element" do

  it "should click" do
    driver.navigate.to Page.form
    driver.find_element(:id, "imageButton").click
  end

  it "should submit" do
    driver.navigate.to Page.form
    driver.find_element(:id, "submitButton").submit
  end

  it "should get value" do
    driver.navigate.to Page.form
    driver.find_element(:id, "cheese").value.should == "cheese"
  end

  it "should send keys" do
    driver.navigate.to Page.form
    driver.find_element(:id, "working").send_keys("foo", "bar")
  end

  it "should get attribute value" do
    driver.navigate.to Page.form
    driver.find_element(:id, "withText").attribute("rows").should == "5"
  end

  it "should toggle" do
    driver.navigate.to Page.form
    driver.find_element(:id, "checky").toggle
  end

  it "should clear" do
    driver.navigate.to Page.form
    driver.find_element(:id, "withText").clear
  end

  it "should get and set selected" do
    driver.navigate.to Page.form
    cheese = driver.find_element(:id, "cheese")
    peas   = driver.find_element(:id, "peas")

    cheese.select

    cheese.should be_selected
    peas.should_not be_selected

    peas.select

    peas.should be_selected
    cheese.should_not be_selected
  end

  it "should get enabled" do
    driver.navigate.to Page.form
    driver.find_element(:id, "notWorking").should_not be_enabled
  end

  it "should get text" do
    driver.navigate.to Page.xhtml
    driver.find_element(:class, "header").text.should == "XHTML Might Be The Future"
  end

  it "should get displayed" do
    driver.navigate.to Page.xhtml
    driver.find_element(:class, "header").should be_displayed
  end

  it "should get location" do
    driver.navigate.to Page.xhtml
    driver.find_element(:class, "header").location.should be_instance_of(WebDriver::Point)
  end

  it "should get size" do
    driver.navigate.to Page.xhtml
    size = driver.find_element(:class, "header").size
  end

  it "should drag and drop" do
    driver.navigate.to Page.drag_and_drop

    img1 = driver.find_element(:id, "test1")
    img2 = driver.find_element(:id, "test2")

    img1.drag_and_drop_by 100, 100
    img2.drag_and_drop_on(img1)

    img1.location.should == img2.location
  end

  it "should get css property" do
    driver.navigate.to Page.javascript
    driver.find_element(:id, "green-parent").style("background-color").should == "#008000"
  end
end
