require "#{File.dirname(__FILE__)}/spec_helper"

describe "Driver" do
  it "should navigate forward and back" do
    driver.navigate.to Page.xhtml
    driver.current_url.should == Page.xhtml
    driver.navigate.to Page.form
    driver.navigate.back
    driver.current_url.should == Page.xhtml
    driver.navigate.forward
    driver.current_url.should == Page.form
  end

  it "should get the page title" do
    driver.navigate.to Page.xhtml
    driver.title.should == "XHTML Test Page"
  end

  it "should get the page source" do
    driver.navigate.to Page.xhtml
    driver.page_source.should match(%r[<title>XHTML Test Page</title>]i)
  end

  describe "one element" do
    it "should find by id" do
      driver.navigate.to Page.xhtml
      element = driver.find_element(:id, "id1")
      element.should be_kind_of(WebDriver::CommonElement)
      element.text.should == "Foo"
    end

    it "should find by field name" do
      driver.navigate.to Page.form
      driver.find_element(:name, "x").value.should == "name"
    end

    it "should find by class name" do
      driver.navigate.to Page.xhtml
      driver.find_element(:class, "header").text.should == "XHTML Might Be The Future"
    end

    it "should find by link text" do
      driver.navigate.to Page.xhtml
      driver.find_element(:link, "Foo").text.should == "Foo"
    end

    it "should find by xpath" do
      driver.navigate.to Page.xhtml
      driver.find_element(:xpath, "//h1").text.should == "XHTML Might Be The Future"
    end

    it "should find child element" do
      driver.navigate.to Page.nested
      element = driver.find_element(:name, "form2")
      child = element.find_element(:name, "selectomatic")
      child.attribute("id").should == "2"
    end

    it "should raise on nonexistant element" do
      driver.navigate.to Page.xhtml
      lambda { driver.find_element("nonexistant") }.should raise_error
    end

    it "should find via alternate syntax" do
      driver.navigate.to Page.xhtml
      driver.find_element(:class => "header").text.should == "XHTML Might Be The Future"
    end
  end

  describe "many elements" do
    it "should find by class name" do
      driver.navigate.to Page.xhtml
      driver.find_elements(:class, "nameC").should have(2).things
    end

    it "should find children by field name" do
      driver.navigate.to Page.nested
      element = driver.find_element(:name, "form2")
      children = element.find_elements(:name, "selectomatic")
      children.should have(2).items
    end
  end

  describe "#execute_script" do

    it "should return strings" do
      driver.navigate.to Page.xhtml
      driver.execute_script("return document.title;").should == "XHTML Test Page"
    end

    it "should return numbers" do
      driver.navigate.to Page.xhtml
      driver.execute_script("return document.title.length;").should == "XHTML Test Page".length
    end

    it "should return elements" do
      driver.navigate.to Page.xhtml
      element = driver.execute_script("return document.getElementById('id1');")
      element.should be_kind_of(WebDriver::CommonElement)
      element.text.should == "Foo"
    end

    it "should return booleans" do
      driver.navigate.to Page.xhtml
      driver.execute_script("return true;").should == true
    end

    it "should raise if the script is bad" do
      driver.navigate.to Page.xhtml
      lambda { driver.execute_script("return squiggle();") }.should raise_error
    end

    it "should be able to call functions on the page" do
      driver.navigate.to Page.javascript
      driver.execute_script("displayMessage('I like cheese');")
      driver.find_element(:id, "result").text.strip.should == "I like cheese"
    end

    it "should be able to pass string arguments" do
      driver.navigate.to Page.javascript
      driver.execute_script("return arguments[0] == 'fish' ? 'fish' : 'not fish';", "fish").should == "fish"
    end

    it "should be able to pass boolean arguments" do
      driver.navigate.to Page.javascript
      driver.execute_script("return arguments[0] == true;", true).should == true
    end

    it "should be able to pass numeric arguments" do
      driver.navigate.to Page.javascript
      driver.execute_script("return arguments[0] == 1 ? 1 : 0;", 1).should == 1
    end

    it "should be able to pass element arguments" do
      driver.navigate.to Page.javascript
      button = driver.find_element(:id, "plainButton")
      driver.execute_script("arguments[0]['flibble'] = arguments[0].getAttribute('id'); return arguments[0]['flibble'];", button).should == "plainButton"
    end

    it "should throw an exception if arguments are invalid"

    it "should be able to pass in multiple arguments" do
      driver.navigate.to Page.javascript
      driver.execute_script("return arguments[0] + arguments[1];", "one", "two").should == "onetwo"
    end

  end

end
