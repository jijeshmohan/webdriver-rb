module WebDriver
  class Navigation

    def initialize(driver)
      @driver = driver
    end

    def to(url)
      @driver.bridge.get url
    end

    def back
      @driver.bridge.back
    end

    def forward
      @driver.bridge.forward
    end

  end
end
