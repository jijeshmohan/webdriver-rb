module WebDriver
  module Find
    
    FINDERS = {
      :class             => 'by_class_name',
      :class_name        => 'by_class_name',
      :id                => 'by_id',
      :link_text         => 'by_link_text',
      :link              => 'by_link_text',
      :partial_link_text => 'by_partial_link_text',
      :name              => 'by_name',
      :tag_name          => 'by_tag_name',
      :xpath             => 'by_xpath',
    }
    
    
    def find_element(*args)
      how, what = extract_args(args)
      
      unless by = FINDERS[how.to_sym]
        raise Error::UnsupportedOperationError, "Cannot find element by #{how.inspect}"
      end
      
      meth = "find_element_#{by}"
      what = what.to_s
      
      bridge.send meth, ref, what
    end

    def find_elements(*args)
      how, what = extract_args(args)
      
      unless by = FINDERS[how.to_sym]
        raise Error::UnsupportedOperationError, "Cannot find elements by #{how.inspect}"
      end
      
      meth = "find_elements_#{by}"
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