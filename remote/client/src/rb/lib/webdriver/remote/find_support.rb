module WebDriver::Remote
  # @api private
  module FindSupport

    protected

    FIND_METHODS = {
      :id    => "id",
      :name  => "name",
      :class => "class name",
      :link  => "link text",
      :xpath => "xpath"
    }

    # Determines the appropriate arguments to specify to the remote server
    # for the given set of arguments to a ruby find method.
    def find_arguments(args)
      raise ArgumentError, "arguments to find are required" if args.length == 0

      # accept alternate syntax:
      #   find_element(:id => "my-id")
      args = args.shift.to_a.flatten if args.first.kind_of? Hash

      raise ArgumentError, "unknown find by method: #{args[0]}" unless FIND_METHODS.key?(args[0])
      method = FIND_METHODS[args[0]] || raise(ArgumentError, "unknown find by method: #{args[0]}")
      [method, args[1]]
    end

  end # FindSupport
end # WebDriver::Remote
