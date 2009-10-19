module WebDriver

  #
  # The WebDriver interface
  #

  class Driver
    include Find

    attr_reader :bridge

    def initialize(driver, *args)
      @bridge = case driver
                when :internet_explorer, :ie
                  WebDriver::IE::Bridge.new(*args)
                when :remote
                  WebDriver::Remote::Bridge.new(*args)
                else
                  raise "unknown driver: #{driver.inspect}"
                end
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
      bridge.current_url
    end

    def title
      bridge.get_title
    end

    def page_source
      bridge.page_source
    end

    def visible?
      bridge.get_visible
    end

    def visible=(bool)
      bridge.set_visible bool
    end

    def quit
      bridge.quit
    end

    def close
      bridge.close
    end

    def window_handles
      bridge.get_window_handles
    end

    def window_handle
      bridge.get_current_window_handle
    end

    def execute_script(*args)
      bridge.execute_script(*args)
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


    private

    #
    # for Find
    #

    def ref
      nil
    end

  end # Driver
end # WebDriver
