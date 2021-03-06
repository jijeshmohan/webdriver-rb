module WebDriver
  module Remote
    class Response

      attr_accessor :code
      attr_writer   :payload

      def initialize
        yield self if block_given?
        assert_ok
      end

      def error
        if payload['error']
          JSON.parse(payload['value'])
        end
      end

      def [](key)
        payload[key]
      end

      def payload
        @payload ||= {}
      end

      private

      def assert_ok
        if @code.nil? || @code > 400
          if e = error()
            raise Error.for_remote_class(e['class']), e['message']
          else
            raise ServerError, self
          end
        end
      end

    end # Response
  end # Remote
end # WebDriver
