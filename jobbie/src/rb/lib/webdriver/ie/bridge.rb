module WebDriver::IE
  class Bridge
    include Util

    attr_reader :driver_pointer
    
    def initialize
      ptr_ref = FFI::MemoryPointer.new :pointer
      
      check_error_code Lib.wdNewDriverInstance(ptr_ref), 
                       "could not create driver instance"
                       
      @driver_pointer = ptr_ref.get_pointer(0)
    end
    
    def get(url)
      check_error_code Lib.wdGet(driver_pointer, wstring_ptr(url)), 
                       "Cannot get url #{url.inspect}"
    end
    
    def current_url
      create_string do |wrapper|
        check_error_code Lib.wdGetCurrentUrl(driver_pointer, wrapper), 
                         "Unable to get current URL"
      end
    end
    
    def get_title
      create_string do |wrapper|
        check_error_code Lib.wdGetTitle(driver_pointer, wrapper),
                         "Unable to get title"
      end
    end
    
    def page_source
      create_string do |wrapper|
        check_error_code Lib.wdGetPageSource(driver_pointer, wrapper),
                         "Unable to get page source"
      end
    end
    
    def get_visible
      int_ptr = FFI::MemoryPointer.new :int
      check_error_code Lib.wdGetVisible(driver_pointer, int_ptr), "Unable to determine if browser is visible"
      
      int_ptr.get_int(0) == 1
    ensure
      int_ptr.free
    end
    
    def set_visible(bool)
      raise NotImplementedError, "function doesn't exist in the current prebuilt DLL?"
      check_error_code Lib.wdSetVisible(driver_pointer, bool ? 1 : 0), 
                       "Unable to change the visibility of the browser"
    end
    
    def switch_to_window(id)
      check_error_code Lib.wdSwitchToWindow(driver_pointer, wstring_ptr(id)), 
                       "Unable to locate window #{id.inspect}"
    end
    
    def switch_to_frame(id)
      check_error_code Lib.wdSwitchToFrame(driver_pointer, wstring_ptr(id)), 
                       "Unable to locate frame #{id.inspect}"
    end

    def switch_to_active_element
      create_element do |ptr|
        check_error_code Lib.wdSwitchToActiveElement(driver_pointer, ptr), 
                         "Unable to switch to active element"
      end
    end
    
    def quit
      get_window_handles.each do |handle|
        switch_to_window handle rescue nil # TODO: rescue specific exceptions
        close
      end

      # TODO: ObjectSpace.each_object(WebDriver::IE::Element) { |e| e.finalize }
    ensure
      Lib.wdFreeDriver(driver_pointer)
      driver_pointer = nil
    end
    
    def close
      check_error_code Lib.wdClose(driver_pointer), "Unable to close driver"
    end
    
    def get_window_handles
      raw_handles = FFI::MemoryPointer.new :pointer
      check_error_code Lib.wdGetAllWindowHandles(driver_pointer, raw_handles),
                       "Unable to obtain all window handles"
                       
      string_array_from(raw_handles).uniq
      # TODO: who calls raw_handles.free if exception is raised?
    end
    
    def get_current_window_handle
      create_string do |string_pointer|
        check_error_code Lib.wdGetCurrentWindowHandle(driver_pointer, string_pointer), 
                         "Unable to obtain current window handle (#{result})"
      end
    end
    
    def execute_script(*args)
      raise NotImplementedError
    end
    
    def wait_for_load_to_complete
      Lib.wdWaitForLoadToComplete(driver_pointer)
    end
    
    #
    # Configuration
    # 
    
    def add_cookie(opts)
      raise NotImplementedError
    end
    
    def delete_cookie(name)
      raise NotImplementedError
    end
    
    def delete_all_cookies
      raise NotImplementedError
    end
    
    #
    # Finders
    # 
    
    def find_element_by_class_name(parent, class_name)
      # TODO: argument checks

      create_element do |raw_element|
        check_error_code Lib.wdFindElementByClassName(driver_pointer, parent, wstring_ptr(class_name), raw_element),
                         "Unable to find element by class name using #{class_name.inspect}"
      end
    end
    
    def find_elements_by_class_name(parent, class_name)
      # TODO: argument checks
      
      create_element_collection do |raw_elements|
        check_error_code Lib.wdFindElementsByClassName(driver_pointer, parent, wstring_ptr(class_name), raw_elements),
                         "Unable to find elements by class name using #{class_name.inspect}"
      end
    end
    
    def find_element_by_id(parent, id)
      create_element do |raw_element|
        check_error_code Lib.wdFindElementById(driver_pointer, parent, wstring_ptr(id), raw_element),
                         "Unable to find element by id using #{id.inspect}"
      end
    end

    def find_elements_by_id(parent, id)
      create_element_collection do |raw_elements|
        check_error_code Lib.wdFindElementsById(driver_pointer, parent, wstring_ptr(id), raw_elements),
                         "Unable to find elements by id using #{id.inspect}"  
      end
    end

    def find_element_by_link_text(parent, link_text)
      create_element do |raw_element|
        check_error_code Lib.wdFindElementByLinkText(driver_pointer, parent, wstring_ptr(link_text), raw_element),
                         "Unable to find element by link text using #{link_text.inspect}"
      end
    end

    def find_elements_by_link_text(parent, link_text)
      create_element_collection do |raw_elements|
        check_error_code Lib.wdFindElementsByLinkText(driver_pointer, parent, wstring_ptr(link_text), raw_elements),
                         "Unable to find elements by link text using #{link_text.inspect}"
      end
    end

    def find_element_by_partial_link_text(parent, link_text)
      create_element do |raw_element|
        check_error_code Lib.wdFindElementByPartialLinkText(driver_pointer, parent, wstring_ptr(link_text), raw_element),
                         "Unable to find element by partial link text using #{link_text.inspect}"
      end
    end

    def find_elements_by_partial_link_text(parent, link_text)
      create_element_collection do |raw_elements|
        check_error_code Lib.wdFindElementsByPartialLinkText(driver_pointer, parent, wstring_ptr(link_text), raw_elements),
                         "Unable to find elements by partial link text using #{link_text.inspect}"
      end
    end
    
    def find_element_by_name(parent, name)
      create_element do |raw_element|
        check_error_code Lib.wdFindElementByName(driver_pointer, parent, wstring_ptr(name), raw_element),
                         "Unable to find element by name using #{name.inspect}"
      end
    end

    def find_elements_by_name(parent, name)
      create_element_collection do |raw_elements| 
        check_error_code Lib.wdFindElementsByName(driver_pointer, parent, wstring_ptr(name), raw_elements),
                         "Unable to find elements by name using #{name.inspect}"
      end
    end

    def find_element_by_tag_name(parent, tag_name)
      create_element do |raw_element|
        check_error_code Lib.wdFindElementByTagName(driver_pointer, parent, wstring_ptr(tag_name), raw_element),
                         "Unable to find element by tag name using #{tag_name.inspect}"
      end
    end
    
    def find_elements_by_tag_name(parent, tag_name)
      create_element_collection do |raw_elements|
        check_error_code Lib.wdFindElementsByTagName(driver_pointer, parent, wstring_ptr(tag_name), raw_element),
                         "Unable to find elements by tag name using #{tag_name.inspect}"
      end
    end
    
    def find_element_by_xpath(parent, xpath)
      create_element do |raw_element|
        check_error_code Lib.wdFindElementByXPath(driver_pointer, parent, wstring_ptr(xpath), raw_element),
                         "Unable to find element by xpath using #{xpath.inspect}"
        # TODO: Additional error handling
      end
    end
    
    def find_elements_by_xpath(parent, xpath)
      create_element_collection do |raw_elements|
        check_error_code Lib.wdFindElementsByXPath(driver_pointer, parent, wstring_ptr(xpath), raw_elements),
                         "Unable to find elements by xpath using #{xpath.inspect}"
        # TODO: Additional error handling
      end
    end
    
    
    #
    # Element functions
    # 
    
    def click_element(element_pointer)
      check_error_code Lib.wdeClick(element_pointer), "Unable to click element"
    end
    
    def get_element_tag_name(element_pointer)
      create_string do |string_pointer|
        check_error_code Lib.wdeGetTagName(element_pointer, string_pointer), 
                         "Unable to get tag name"
      end
    end
    
    def get_element_attribute(element_pointer, name)
      create_string do |string_pointer|
        check_error_code Lib.wdeGetAttribute(element_pointer, wstring_ptr(name), string_pointer),
                         "Unable to get attribute #{name.inspect}"
      end
    end
    
    def get_element_text(element_pointer)
      create_string do |string_pointer|
        check_error_code Lib.wdeGetText(element_pointer, string_pointer),
                         "Unable to get text"
      end
    end
    
    def send_keys(element_pointer, string)
      check_error_code Lib.wdeSendKeys(element_pointer, wstring_ptr(string)),
                       "Unable to send keys to #{self}"
      wait_for_load_to_complete
    end
    
    def clear_element(element_pointer)
      check_error_code Lib.wdeClear(element_pointer), "Unable to clear element" 
    end
    
    def is_element_enabled(element_pointer)
      int_ptr = FFI::MemoryPointer.new(:int)
      check_error_code Lib.wdeIsEnabled(element_pointer, int_ptr), 
                       "Unable to get enabled state"
      
      int_ptr.get_int(0) == 1
    ensure
      int_ptr.free
    end
    
    def is_element_selected(element_pointer)
      int_ptr = FFI::MemoryPointer.new(:int)
      check_error_code Lib.wdeIsSelected(element_pointer, int_ptr), 
                       "Unable to get selected state"

      int_ptr.get_int(0) == 1
    ensure
      int_ptr.free
    end
    
    def is_element_displayed(element_pointer)
      int_ptr = FFI::MemoryPointer.new :int
      check_for_error Lib.wdeIsDisplayed(element_pointer, int_ptr), "Unable to check visibilty"

      int_ptr.get_int(0) == 1;
    ensure
      int_ptr.free
    end
    
    def submit_element(element_pointer)
      check_error_code Lib.wdeSubmit(element_pointer), "Unable to submit element"
    end
    
    def toggle_element(element_pointer)
      int_ptr = FFI::MemoryPointer.new :int
      result = Lib.wdeToggle(element_pointer, int_ptr)

      if result == 9
        raise WebDriver::UnsupportedOperationError, 
          "You may not toggle this element: #{get_element_tag_name(element_pointer)}"
      end

      check_error_code result, "Unable to toggle element"
      
      int_ptr.get_int(0) == 1
    ensure
      int_ptr.free
    end
    
    def get_value_of_css_property(element_pointer, prop)
      create_string do |string_pointer|
        check_error_code Lib.wdeGetValueOfCssProperty(@element_ptr, wstring_ptr(prop), wrapper),
                         "Unable to get value of css property: #{prop.inspect}"
      end
    end
    
    def hover
      raise NotImplementedError
    end
    
    def get_element_location
      raise NotImplementedError
    end
    
    def get_element_size
      raise NotImplementedError
    end
    
    def finalize(element_pointer)
      # FIXME: ouch
      
      p :finalizing => element_pointer
      check_error_code Lib.wdFreeElement(element_pointer),
                       "Unable to finalize #{self}"
    end

    private
    
    def check_error_code(code, message)
      e = WebDriver::Error.for_code(code)
      raise e, "#{message} (#{code})" if e
    end
    
  end # Bridge
end # WebDriver::IE