
module WebDriver
  module Error
    # REMOTE_EXCEPTIONS = {
    #   'org.openqa.selenium.NoSuchElementException' => NoSuchElementError,
    #   'org.openqa.selenium.NoSuchFrameException'   => NoSuchFrameError,
    #   'org.openqa.selenium.NoSuchWindowException'  => NoSuchWindowError,
    # }
    #
    # class << self
    #   def for_remote_class(klass)
    #     REMOTE_EXCEPTIONS[klass] || RuntimeError
    #   end
    # end

    # Error that ocurred on the remote server.
    class ServerError < StandardError

      class << self

        EXCEPTIONS = {}

        def remote_class_name
          "org.openqa.selenium." + self.name.gsub(/^.*::/, "")
        end

        def inherited(subclass)
          EXCEPTIONS[subclass.remote_class_name] = subclass
        end

        def json_create(data)
          local_class = EXCEPTIONS[data["value"]["class"]] || self
          local_class.new(data)
        end

      end

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

  end # Error
end # WebDriver
