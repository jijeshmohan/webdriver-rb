module WebDriver
  class Options

    def initialize(driver)
      @bridge = driver.bridge
    end

    def add_cookie(opts = {})
      raise ArgumentError, "name is required" unless opts[:name]
      raise ArgumentError, "value is required" unless opts[:value]
      
      opts[:path] ||= "/"
      opts[:secure] ||= false
      
      @bridge.add_cookie opts
    end

    def delete_cookie(name)
      @bridge.delete_cookie name
    end

    def delete_all_cookies
      @bridge.delete_all_cookies
    end

    def all_cookies
      @bridge.get_all_cookies.map do |cookie|
        { 
          :name    => cookie["name"],
          :value   => cookie["value"],
          :path    => cookie["path"],
          :domain  => cookie["domain"],
          :expires => nil,
          :secure  => cookie["secure"] 
        }
      end
    end

    def speed
      @bridge.get_speed.downcase.to_sym
    end

    def speed=(speed)
      @bridge.set_speed(speed.to_s.upcase)
    end

  end
end