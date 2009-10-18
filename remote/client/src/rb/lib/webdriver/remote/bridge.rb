require "json"
require "net/http"
require "uri"

module WebDriver
  module Remote

    DEBUG = $VERBOSE == true
    
    COMMANDS = {}
    
    #
    # Low level bridge to the remote server, through which the rest of the API works.
    # 
    # @api private
    #

    class Bridge
      include Find
      
      DEFAULT_OPTIONS = {
        :server_url           => "http://localhost:7055/",
        :http_client          => DefaultHttpClient,
        :desired_capabilities => Capabilities.firefox
      }

      #
      # Defines a wrapper method for a command, which ultimately calls #invoke.
      #
      # @param name [Symbol]
      #   name of the resulting method
      # @param url [String]
      #   a URL template, which can include some arguments, much like the definitions on the server.
      #   the :session_id and :context parameters are implicitly handled, but the remainder will become
      #   required method arguments.
      #   e.g., "session/:session_id/:context/element/:id/text" will define a method that takes id
      #   as it's first argument.
      # @param verb [Symbol]
      #   the appropriate http verb, such as :get, :post, or :delete
      #

      def self.command(name, verb, url)
        COMMANDS[name] = [verb, url.freeze]
      end

      attr_accessor :context, :http
      attr_reader :capabilities

      #
      # Initializes the bridge with the given server URL.
      #
      # @param server_url [String] base URL for all commands.  Note that a trailing '/' is very important!
      #

      def initialize(opts = {})
        opts          = DEFAULT_OPTIONS.merge(opts)
        @context      = "context"
        @server_url   = URI.parse(opts[:server_url])
        @http         = opts[:http_client].new(@server_url)
        @capabilities = create_session opts[:desired_capabilities]
      end
      
      #
      # Returns the current session ID.
      #

      def session_id
        @session_id || raise(StandardError, "no current session exists")
      end
      

      def create_session(desired_capabilities)
        resp  = raw_invoke :new_session, {}, desired_capabilities
        @session_id = resp['sessionId'] || raise('no sessionId in returned payload')
        Capabilities.json_create resp['value']
      end
      
      def get(url)
        invoke :get, {}, url
      end
      
      def back
        invoke :back
      end
      
      def forward
        invoke :forward
      end
      
      def current_url
        invoke :current_url
      end
      
      def get_title
        invoke :get_title
      end
      
      def page_source
        invoke :page_source
      end
      
      def get_visible
        invoke :get_visible
      end
      
      def set_visible(bool)
        invoke :set_visible, {}, bool
      end
      
      def switch_to_window(name)
        invoke :switch_to_window, :name => name
      end
      
      def switch_to_frame(id)
        invoke :switch_to_frame, :id => id
      end
      
      def quit
        invoke :quit
      end
      
      def close
        invoke :close
      end
      
      def get_window_handles
        invoke :get_window_handles
      end
      
      def get_current_window_handle
        invoke :get_current_window_handle
      end
      
      def set_speed(value)
        invoke :set_speed, {}, value
      end
      
      def get_speed
        invoke :get_speed
      end
      
      def execute_script(script, *args)
        raise UnsupportedOperationError, "underlying webdriver instace does not support javascript" unless capabilities.javascript_enabled?

        # remote server requires type information for all arguments
        typed_args = args.collect do |arg|
          case arg
          when Integer, Float
            { :type => "NUMBER", :value => arg }
          when TrueClass, FalseClass
            { :type => "BOOLEAN", :value => arg }
          when Element 
            { :type => "ELEMENT", :value => arg.ref }
          else 
            { :type => "STRING", :value => arg.to_s }
          end
        end

        response = raw_invoke :execute_script, {}, script, typed_args
        
        # un-type the result value
        result = response['value']
        case result["type"]
        when "ELEMENT"
          Element.new(self, element_id_from(result["value"]))
        else 
          result["value"]
        end
      end
      
      def add_cookie(cookie)
        invoke :add_cookie, {}, cookie
      end
      
      def delete_cookie(name)
        invoke :delete_cookie, :name => name
      end
      
      def get_all_cookies
        invoke :get_all_cookies
      end
      
      def delete_all_cookies
        invoke :delete_all_cookies
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
        invoke :click_element, :id => element
      end

      def get_element_tag_name(element)
        invoke :get_tag_name, :id => element
      end

      def get_element_attribute(element, name)
        invoke :get_element_attribute, :id => element, :name => name
      end

      def get_element_value(element)
        invoke :get_element_value, :id => element
      end

      def get_element_text(element)
        invoke :get_element_text, :id => element
      end

      def get_element_location(element)
        data = invoke :get_element_location, :id => element
        Point.new data['x'], data['y']
      end

      def get_element_size(element)
        invoke :get_element_size, :id => element
      end
      
      def send_keys(element, string)
        invoke :send_keys, {:id => element}, {:value => string.split(//u)} 
      end

      def clear_element(element)
        invoke :clear_element, :id => element
      end

      def is_element_enabled(element)
        invoke :is_element_enabled, :id => element
      end

      def is_element_selected(element)
        invoke :is_element_selected, :id => element
      end

      def is_element_displayed(element)
        invoke :is_element_displayed, :id => element
      end

      def submit_element(element)
        invoke :submit_element, :id => element
      end

      def toggle_element(element)
        invoke :toggle_element, :id => element
      end
      
      def set_element_selected(element)
        invoke :set_element_selected, :id => element
      end

      def get_value_of_css_property(element, prop)
        invoke :get_value_of_css_property, :id => element, :property_name => prop
      end
      
      def get_active_element
        id = invoke :get_active_element
        Element.new self, element_id_from(id)
      end
      alias_method :switch_to_active_element, :get_active_element

      def hover
        invoke :hover, :id => element
      end

      private
      
      def find_element_by(how, what, parent = nil)
        if parent
          id = invoke :find_element_using_element, {:id => parent, :using => how}, {:using => how, :value => what}
        else
          id = invoke :find_element, {}, how, what
        end
        
        Element.new self, element_id_from(id)
      end
      
      def find_elements_by(how, what, parent = nil)
        if parent
          ids = invoke :find_elements_using_element, {:id => parent, :using => how}, {:using => how, :value => what}
        else
          ids = invoke :find_elements, {}, how, what
        end
        
        ids.map { |id| Element.new self, element_id_from(id) }
      end
      
      
      #
      # Invokes a command on the remote server via the REST / JSON API.
      #
      #
      # Returns the 'value' of the returned payload
      # 
      
      def invoke(*args)
        raw_invoke(*args)['value']
      end
      
      #
      # Invokes a command on the remote server via the REST / JSON API.
      #
      # Returns a WebDriver::Remote::Response instance
      #
      
      def raw_invoke(command, opts = {}, *args)
        verb, path = COMMANDS[command] || raise("Unknown command #{command.inspect}")
        path       = path.dup
        
        path[':session_id'] = @session_id if path.include?(":session_id")
        path[':context']    = @context if path.include?(":context")
        
        begin
          opts.each { |key, value| path[key.inspect] = value }
        rescue IndexError
          raise ArgumentError, "#{opts.inspect} invalid for #{command.inspect}"
        end
        
        puts "-> #{verb.to_s.upcase} #{path}" if DEBUG
        http.call verb, path, *args
      end
      
      def element_id_from(arr)
        arr.first.split("/").last
      end


    end # Bridge
  end # Remote
end # WebDriver
