module WebDriver
  class Options

    def initialize(driver)
      @driver = driver
    end

    def add_cookie(opts = {})
      raise ArgumentError, "name is required" unless opts[:name]
      raise ArgumentError, "value is required" unless opts[:value]
      
      opts[:path] ||= "/"
      opts[:secure] ||= false
      
      @driver.bridge.add_cookie opts
    end

    def delete_cookie(name)
      @driver.bridge.delete_cookie name
    end

    def delete_all_cookies
      @driver.bridge.delete_all_cookies
    end

    def all_cookies
      @driver.bridge.get_all_cookies.value.collect do |cookie|
        { :name    => cookie["name"],
          :value   => cookie["value"],
          :path    => cookie["path"],
          :domain  => cookie["domain"],
          :expires => nil,
          :secure  => cookie["secure"] }
      end
    end

    def speed
      @driver.bridge.get_speed.value.downcase.to_sym
    end

    def speed=(speed)
      @driver.bridge.set_speed(speed.to_s.upcase)
    end

  end
end