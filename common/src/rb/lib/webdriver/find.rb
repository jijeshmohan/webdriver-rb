module WebDriver
  module Find

    FINDERS = {
      :class             => 'ByClassName',
      :class_name        => 'ByClassName',
      :id                => 'ById',
      :link_text         => 'ByLinkText',
      :link              => 'ByLinkText',
      :partial_link_text => 'ByPartialLinkText',
      :name              => 'ByName',
      :tag_name          => 'ByTagName',
      :xpath             => 'ByXpath',
    }


    def find_element(*args)
      how, what = extract_args(args)

      unless by = FINDERS[how.to_sym]
        raise Error::UnsupportedOperationError, "Cannot find element by #{how.inspect}"
      end

      meth = "findElement#{by}"
      what = what.to_s

      bridge.send meth, ref, what
    end

    def find_elements(*args)
      how, what = extract_args(args)

      unless by = FINDERS[how.to_sym]
        raise Error::UnsupportedOperationError, "Cannot find elements by #{how.inspect}"
      end

      meth = "findElements#{by}"
      what = what.to_s

      bridge.send meth, ref, what
    end

    private

    def extract_args(args)
      case args.size
      when 2
        args
      when 1
        arg = args.first
        unless arg.respond_to?(:shift)
          raise ArgumentError, "expected #{arg.inspect}:#{arg.class} to respond to #shift"
        end

        arr = arg.shift
        unless arr.size == 2
          raise ArgumentError, "expected #{arr.inspect} to have 2 elements"
        end

        arr
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 2)"
      end
    end

  end # Find
end # WebDriver