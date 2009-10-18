module WebDriver
  module IE
    class Element < CommonElement
      def initialize(parent, element_ptr)
        super
        
        if @id.nil? || @id.null?
          raise WebDriver::NullPointerError, "element pointer is nil or null" 
        end
      end
    
      # def click
      #   bridge.click_element @element_ptr
      # end
      # 
      # def tag_name
      #   bridge.get_tag_name @element_ptr
      # end
      # 
      # def attribute(name)
      #   bridge.get_element_attribute @element_ptr, name
      # end
      # 
      # def text
      #   bridge.get_text @element_ptr
      # end
      # 
      # def value
      #   attribute(:value).gsub("\r\n", "\n")
      # end
      # 
      # def send_keys(*args)
      #   args.each { |str| bridge.send_keys(@element_ptr, str) }
      # end
      # 
      # def clear
      #   bridge.clear_element @element_ptr
      # end
      # 
      # def enabled?
      #   bridge.is_element_enabled @element_ptr
      # end
      # 
      # def selected?
      #   bridge.is_element_selected @element_ptr
      # end
      # 
      # def displayed?
      #   bridge.is_element_displayed @element_ptr
      # end
      #     
      # def select
      #   bridge.set_element_selected @element_ptr
      # end
      # 
      # def submit
      #   bridge.submit_element @element_ptr
      # end
      # 
      # def toggle
      #   bridge.toggle_element @element_ptr
      # end
      # 
      # def style(prop)
      #   bridge.get_value_of_css_property @element_ptr, prop
      # end
      # 
      # def hover
      #   bridge.hover @element_ptr
      # end
      # 
      # def location
      #   bridge.get_element_location @element_ptr
      # end
      # 
      # def size
      #   bridge.get_element_size @element_ptr
      # end
      # 
      # def drag_and_drop_by(right_by, down_by)
      #   raise NotImplementedError
      # end
      # 
      # def drag_and_drop_on(other)
      #   raise NotImplementedError
      # end

    end # Element
  end # IE
end # WebDriver
