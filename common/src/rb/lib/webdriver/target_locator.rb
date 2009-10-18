module WebDriver
  class TargetLocator

    def initialize(driver)
      @driver = driver
    end

    def frame(id)
      @driver.bridge.switch_to_frame id
    end

    def window(id)
      @driver.bridge.switch_to_window id
    end

    def active_element
      @driver.bridge.switch_to_active_element
    end

  end
end
