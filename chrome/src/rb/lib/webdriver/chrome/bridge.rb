module WebDriver
  module Chrome
    class Bridge
      def initialize
        @executor = CommandExecutor.new

        @launcher = Launcher.new
        @launcher.launch
        # TODO: @launcher.kill
      end

      def get(url)
        execute :request => 'url', :url => url
      end

      def back
        execute :request => 'goBack'
      end

      def forward
        execute :request => 'goForward'
      end

      def current_url
        execute :request => 'getCurrentUrl'
      end

      def get_title
        execute :request => 'getTitle'
      end

      def page_source
        execute :request => 'getPageSource'
      end

      def switch_to_window(name)
        execute :request => 'switchToWindow', :windowName => name
      end

      def switch_to_frame(id)
        execute :request => 'switchToFrameByName', :name => id
      end

      def quit
        execute :request => 'quit'
      end

      def close
        execute :request => 'close'
      end

      def get_window_handles
        execute :request => 'getWindowHandles'
      end

      def get_current_window_handle
        execute :request => 'getCurrentWindowHandle'
      end

      def set_speed(value)
        @speed = value
      end

      def get_speed
        @speed
      end

      def execute_script(script, *args)
        raise NotImplementedError
        execute :request => 'execute', :script => script, :args => args
      end

      def add_cookie(cookie)
        execute :request => 'addCookie', :cookie => cookie
      end

      def delete_cookie(name)
        execute :request => 'deleteCookie', :name => name
      end

      def get_all_cookies
        execute :request => 'getAllCookies'
      end

      def delete_all_cookies
        execute :request => 'deleteAllCookies'
      end

      def find_element_by_class_name(parent, class_name)
        find_element_by 'class name', class_name, parent
      end

      def find_elements_by_class_name(parent, class_name)
        find_elements_by 'class name', class_name, parent
      end

      def find_element_by_id(parent, id)
        find_element_by 'id', id, parent
      end

      def find_elements_by_id(parent, id)
        find_elements_by 'id', id, parent
      end

      def find_element_by_link_text(parent, link_text)
        find_element_by 'link text', link_text, parent
      end

      def find_elements_by_link_text(parent, link_text)
        find_elements_by 'link text', link_text, parent
      end

      def find_element_by_partial_link_text(parent, link_text)
        find_element_by 'partial link text', link_text, parent
      end

      def find_elements_by_partial_link_text(parent, link_text)
        find_elements_by 'partial link text', link_text, parent
      end

      def find_element_by_name(parent, name)
        find_element_by 'name', name, parent
      end

      def find_elements_by_name(parent, name)
        find_elements_by 'name', name, parent
      end

      def find_element_by_tag_name(parent, tag_name)
        find_element_by 'tag name', tag_name, parent
      end

      def find_elements_by_tag_name(parent, tag_name)
        find_elements_by 'tag name', tag_name, parent
      end

      def find_element_by_xpath(parent, xpath)
        find_element_by 'xpath', xpath, parent
      end

      def find_elements_by_xpath(parent, xpath)
        find_elements_by 'xpath', xpath, parent
      end


      #
      # Element functions
      #

      def click_element(element)
        execute :request => 'clickElement', :elementId => element
      end

      def get_element_tag_name(element)
        execute :request => 'getElementTagName', :elementId => element
      end

      def get_element_attribute(element, name)
        execute :request => 'getElementAttribute', :elementId => element, :attribute => name
      end

      def get_element_value(element)
        execute :request => 'getElementValue', :elementId => element
      end

      def get_element_text(element)
        execute :request => 'getElementText', :elementId => element
      end

      def get_element_location(element)
        data = execute :request => 'getElementLocation', :elementId => element

        Point.new data['x'], data['y']
      end

      def get_element_size(element)
        execute :request => 'getElementSize', :elementId => element
      end

      def send_keys(element, string)
        execute :request => 'sendElementKeys', :elementId => element, :keys => string.split(//u)
      end

      def clear_element(element)
        execute :request => 'clearElement', :elementId => element
      end

      def is_element_enabled(element)
        execute :request => 'isElementEnabled', :elementId => element
      end

      def is_element_selected(element)
        execute :request => 'isElementSelected', :elementId => element
      end

      def is_element_displayed(element)
        execute :request => 'isElementDisplayed', :elementId => element
      end

      def submit_element(element)
        execute :request => 'submitElement', :elementId => element
      end

      def toggle_element(element)
        execute :request => 'toggleElement', :elementId => element
      end

      def set_element_selected(element)
        execute :request => 'setElementSelected', :elementId => element
      end

      def get_value_of_css_property(element, prop)
        execute :request => 'getElementValueOfCssProperty', :elementId => element, :css => prop
      end

      def get_active_element
        Element.new self, element_id_from(execute(:request => 'getActiveElement'))
      end
      alias_method :switch_to_active_element, :get_active_element

      def hover
        execute :request => 'hoverElement', :elementId => element
      end

      def drag_and_drop_by(element, rigth_by, down_by)
        raise NotImplementedError
        execute :drag_element, {:id => element}, element, rigth_by, down_by
      end

      private

      def find_element_by(how, what, parent = nil)
        if parent
          id = execute :request => 'findChildElement', :id => parent, :using => how, :value => what
        else
          id = execute :request => 'findElement', :using => how, :value => what
        end

        Element.new self, element_id_from(id)
      end

      def find_elements_by(how, what, parent = nil)
        if parent
          ids = execute :request => 'findChildElements', :id => parent, :using => how, :value => what
        else
          ids = execute :request => 'findElements', :using => how, :value => what
        end

        ids.map { |id| Element.new self, element_id_from(id) }
      end


      private

      def execute(command)
        resp = raw_execute command
        code = resp['statusCode']
        if e = Error.for_code(code)
          msg = resp['value']['message'] if resp['value']
          msg ||= "unknown exception for #{command.inspect}"
          msg << " (#{code})"

          raise e, msg
        end

        resp['value']
      end

      def raw_execute(command)
        @executor.execute command
      end

      # hack!
      def element_id_from(arr)
        arr.to_s.split("/").last
      end


    end # Bridge
  end # Chrome
end # WebDriver
