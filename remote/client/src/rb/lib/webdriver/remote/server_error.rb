module WebDriver
  module Error
    class ServerError < StandardError

      def initialize(response)
        @response = response
        if response.error
          super(response.error["message"])
        else
          super("status code #{response.code}")
        end
      end

      # def to_s
      #   self.class.name + ": " + @data["value"]["class"] + ": " + @data["value"]["message"]
      # end
    end

    REMOTE_EXCEPTIONS = {
      'org.openqa.selenium.NoSuchElementException' => NoSuchElementError,
      'org.openqa.selenium.NoSuchFrameException'   => NoSuchFrameError,
      'org.openqa.selenium.NoSuchWindowException'  => NoSuchWindowError,
    }

    class << self
      def for_remote_class(klass)
        REMOTE_EXCEPTIONS[klass] || ServerError
      end
    end

  end # Error
end # WebDriver
