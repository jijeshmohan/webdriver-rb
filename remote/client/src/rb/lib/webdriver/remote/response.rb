module WebDriver::Remote
  
  #
  # Encapsulation of the server side response to a command.
  #
  # @option value               the response value from the server, if any
  # @option context    [String] the webdriver context (window, frame, etc.)
  # @option session_id [String] the webdriver session id
  # @option error      [Boolean] whether an error occurred
  #
  # @api public
  #
  class Response

    attr_reader :value, :context, :session_id

    def initialize(opts = {})
      @value      = opts[:value]
      @context    = opts[:context]
      @session_id = opts[:session_id]
      @error      = opts[:error]
    end

    # @api private
    def self.json_create(data)
      new(
        :value      => data["value"],
        :context    => data["context"],
        :session_id => data["sessionId"],
        :error      => data["error"]
      )
    end

    def error?
      @error
    end

  end
end