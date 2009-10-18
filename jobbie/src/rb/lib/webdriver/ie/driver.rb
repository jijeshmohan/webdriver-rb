module WebDriver
  module IE
    class Driver < CommonDriver

      def initialize
        super(Bridge.new)
      end
      
    end # Driver
  end # IE 
end # WebDriver

