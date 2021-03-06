module WebDriver
  class Driver
    include Find

    attr_reader :bridge

    class << self
      def for(driver, *args)
        case driver
        when :ie, :internet_explorer
          new WebDriver::IE::Bridge.new(*args)
        when :remote
          new WebDriver::Remote::Bridge.new(*args)
        when :chrome
          new WebDriver::Chrome::Bridge.new(*args)
        when :firefox, :ff
          new WebDriver::Firefox::Bridge.new(*args)
        else
          raise ArgumentError, "unknown driver: #{driver.inspect}"
        end
      end
    end

    def initialize(bridge)
      @bridge = bridge
    end

    def navigate
      @navigate ||= WebDriver::Navigation.new(self)
    end

    def switch_to
      @switch_to ||= WebDriver::TargetLocator.new(self)
    end

    def manage
      @manage ||= WebDriver::Options.new(self)
    end

    def current_url
      bridge.getCurrentUrl
    end

    def title
      bridge.getTitle
    end

    def page_source
      bridge.getPageSource
    end

    def visible?
      bridge.getBrowserVisible
    end

    def visible=(bool)
      bridge.setBrowserVisible bool
    end

    def quit
      bridge.quit
    end

    def close
      bridge.close
    end

    def window_handles
      bridge.getWindowHandles
    end

    def window_handle
      bridge.getCurrentWindowHandle
    end

    def execute_script(script, *args)
      bridge.executeScript(script, *args)
    end

    #-------------------------------- sugar  --------------------------------

    #
    # driver.first(:id, 'foo')
    #

    alias_method :first, :find_element

    #
    # driver.all(:class, 'bar') #=> [#<WebDriver::Element:0x1011c3b88, ...]
    #

    alias_method :all, :find_elements

    #
    # opens the specified URL in the browser.
    #

    def get(url)
      navigate.to(url)
    end

    #
    # driver.script('function() { ... };')
    #

    alias_method :script, :execute_script

    #
    # driver['someElementId'] #=> #<WebDriver::Element:0x1011c3b88>
    #

    def [](id)
      find_element :id, id
    end


    #
    # for Find
    #

    def ref
      nil
    end

  end # Driver
end # WebDriver
