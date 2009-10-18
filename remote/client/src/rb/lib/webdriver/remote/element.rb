module WebDriver
  module Remote

    #
    # Contextually aware interface to an element in the remote document.
    # @api public
    #

    class Element < CommonElement
      def initialize(driver, id)
        id = id.split("/").last    # hack: same as in the java client
        super
      end

      def ref
        @id
      end

      def send_keys(*args)
        bridge.send_keys @id, :id => @id, :value => args
      end

      def attribute(name)
        super.value
      end

      def toggle
        bridge.toggle_element @id
      end

      def selected?
        super.value
      end

      def selected=(selected)
        select # FIXME
      end

      def enabled?
        super.value
      end

      def text
        super.value
      end

      def displayed?
        super.value
      end

      def location
        # FIXME
        data = bridge.get_element_location(@id).value
        WebDriver::Point.new data["x"], data["y"]
      end

      def size
        super.value
      end

      def drag_and_drop_by(move_right_by, move_down_by)
        # another spot where we're specifying the id in the payload
        bridge.drag_element @id, @id, move_right_by, move_down_by
      end

      def drag_and_drop_on(element)
        current_location = self.location
        destination      = element.location
        right            = destination.x - current_location.x
        down             = destination.y - current_location.y

        drag_and_drop_by right, down
      end

      def style(property_name)
        super.value
      end

      include FindSupport

      #
      # Finds a single child element.
      #
      # @see Driver#find_element
      #

      def find_element(*args)
        using, value = find_arguments(args)
        id = bridge.find_element_using_element(@id, using, :using => using, :value => value).value
        Element.new(@driver, id[0])
      end

      #
      # Finds a set of child elements.
      #
      # @see Driver#find_elements
      #

      def find_elements(*args)
        using, value = find_arguments(args)
        ids = bridge.find_elements_using_element(@id, using, :using => using, :value => value ).value
        ids.map { |id| Element.new(@driver, id) }
      end

      
    end # Element
  end # Remote
end # WebDriver
