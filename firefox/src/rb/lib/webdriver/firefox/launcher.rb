module WebDriver
  module Firefox
    class Launcher
      
      DEFAULT_PROFILE_NAME = "WebDriver".freeze
      DEFAULT_PORT         = 7055
      
      attr_reader :binary, :connection
      
      def launch
        connect_and_kill 
        create_profile
        start
        connect_until_stable
        connect
        
        self
      end
      
      def initialize(binary, port = DEFAULT_PORT, profile_name = DEFAULT_PROFILE_NAME)
        @binary       = binary
        @port         = port
        @profile_name = profile_name
        @profile      = nil
      end
      
      def start
        raise "must create_profile first" if @profile.nil?
        @binary.start_with @profile
        @binary.wait
      end
      
      def connect_and_kill
        connection = ExtensionConnection.new("0.0.0.0", @port)
        connection.connect(1)
        connection.quit
      rescue Errno::ECONNREFUSED, Timeout::Error => e 
        $stderr.puts "connect_and_kill caught #{e.message}"
      end
      
      def create_profile
        @profile = Profile.new() #Profile.create(@binary, @profile_name, @port)
      end
      
      def connect
        @connection = ExtensionConnection.new("0.0.0.0", @port)
        @connection.connect(5)
        sleep 2
        p :connected => @connection
      end
      
      def connect_until_stable
        max_time = Time.now + 60
        
        until Time.now >= max_time
          begin
            connection = ExtensionConnection.new("0.0.0.0", @port)
            connection.connect(1)
            sleep 2
            connection.quit
            return
          rescue Timeout::Error => e
            p :not_stable => e
          end
        end
        
        raise Error::WebDriverError, "unable to obtain stable firefox connection"
      end
      
    end # Launcher
  end # Firefox
end # WebDriver