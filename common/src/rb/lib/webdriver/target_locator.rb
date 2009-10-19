module WebDriver
  class TargetLocator

    def initialize(driver)
      @bridge = driver.bridge
    end

    def frame(id)
      @bridge.switch_to_frame id
    end

    def window(id)
      @bridge.switch_to_window id
    end

    def active_element
      @bridge.switch_to_active_element
    end

  end
end
