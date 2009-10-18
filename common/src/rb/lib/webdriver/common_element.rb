module WebDriver
  
  # 
  # The WebElement interface
  # 
  
  class CommonElement
    include Find
    
    attr_reader :parent

    def initialize(parent, id)
      @parent, @id = parent, id
    end
    
    def ref
      @id
    end

    def bridge
      @parent
    end

    def click
      bridge.click_element @id
    end

    def tag_name
      bridge.get_tag_name @id
    end
    
    def value
      bridge.get_element_value @id
    end

    def attribute(name)
      bridge.get_element_attribute @id, name
    end

    def text
      bridge.get_element_text @id
    end

    def value
      attribute(:value).gsub("\r\n", "\n")
    end

    def send_keys(*args)
      args.each { |str| bridge.send_keys(@id, str) }
    end

    def clear
      bridge.clear_element @id
    end

    def enabled?
      bridge.is_element_enabled @id
    end

    def selected?
      bridge.is_element_selected @id
    end

    def displayed?
      bridge.is_element_displayed @id
    end
    
    def select
      bridge.set_element_selected @id
    end

    def submit
      bridge.submit_element @id
    end

    def toggle
      bridge.toggle_element @id
    end

    def style(prop)
      bridge.get_value_of_css_property @id, prop
    end

    def hover
      bridge.hover @id
    end

    def location
      bridge.get_element_location @id
    end

    def size
      bridge.get_element_size @id
    end

    def drag_and_drop_by(right_by, down_by)
      raise NotImplementedError
    end

    def drag_and_drop_on(other)
      raise NotImplementedError
    end

  end # Element
end # WebDriver::IE
