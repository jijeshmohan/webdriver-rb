module WebDriver
  module Error
    class ServerError < StandardError

      def initialize(response)
        return super(response) if response.kind_of?(String)

        if response.error
          super(response.error["message"])
        else
          super("status code #{response.code}")
        end
      end

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
