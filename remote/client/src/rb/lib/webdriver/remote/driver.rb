module WebDriver
  module Remote
    # The primary interface to the remote web browser.
    # @api public
    class Driver < CommonDriver

      DEFAULT_SERVER_URL           = "http://localhost:7055/"
      DEFAULT_DESIRED_CAPABILITIES = Capabilities.firefox

      attr_reader :capabilities

      #
      # Creates a new driver instance.
      #
      # @option server_url [String]
      #   The URL of the remote server.  Note that if the remote server is not deployed in the
      #   root context, a trailing slash is very important here!
      # @option desired_capabilities [Capabilities]
      #   Describes the requirements for the test browser.
      #
      def initialize(opts = {})
        super(Bridge.new(opts[:server_url] || DEFAULT_SERVER_URL))
        
        @capabilities = @bridge.create_session(opts[:desired_capabilities] || DEFAULT_DESIRED_CAPABILITIES)
      end

      def title
        super.value
      end

      def current_url
        super.value
      end

      def page_source
        super.value
      end

      # Execute some arbitrary javascript in the browser.
      #
      # Note that the javascript_enabled capability must have been requested!
      def execute_script(script, *args)
        raise StandardError, "underlying webdriver instace does not support javascript" unless capabilities.javascript_enabled?

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

        # execute the script
        response = bridge.execute_script(script, typed_args)

        # un-type the result value
        result = response.value
        case result["type"]
        when "ELEMENT"
          Element.new(self, result["value"])
        else 
          result["value"]
        end
      end

      include FindSupport

      #
      # Finds a single element in the browser, given a method and a (method specific) selector.
      #
      #   driver.find_element(:xpath, "//*[@id='my-id']")
      #
      # or the equivalent:
      #
      #   driver.find_element(:id, "my-id")
      #
      # or more succinctly:
      #
      #   driver["my-id"]
      #
      # The last form is a shortcut for finding by id.
      #
      # @param method [Symbol]
      #   One of:
      #   <dl>
      #     <dt> :id    <dd> id of the element to find
      #     <dt> :name  <dd> name of the element to find
      #     <dt> :class <dd> css class name of the element to find
      #     <dt> :link  <dd> link text of the element to find
      #     <dt> :xpath <dd> xpath selector of the element to find
      #   </dl>
      # @param selector [String]        Method specific selector
      # @return         [RemoteElement] Reference to the element
      # @raiseRemoteError               if the element could not be found
      #

      def find_element(*args)
        id = bridge.find_element(*find_arguments(args)).value
        Element.new(self, id[0])
      end

      # Finds a set of elements in the browser.
      # @see #find_element
      def find_elements(*args)
        ids = bridge.find_elements(*find_arguments(args)).value
        ids.collect { |id| Element.new(self, id) }
      end

    end # Driver
  end # Remote
end # WebDriver
