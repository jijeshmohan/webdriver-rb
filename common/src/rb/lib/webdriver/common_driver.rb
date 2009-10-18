module WebDriver
  
  #
  # The WebDriver interface
  # 
  
  class CommonDriver
    include Find

    attr_reader :bridge

    def initialize(bridge)
      @bridge = bridge
    end
    
    def ref
      nil
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
    
  end # CommonDriver
end # WebDriver
