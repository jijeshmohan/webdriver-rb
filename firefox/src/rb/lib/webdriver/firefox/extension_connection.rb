module WebDriver
  module Firefox
    class ExtensionConnection

      def initialize(host, port)
        @host = host
        @port = port
      end
      
      def connect(timeout = 20)
        Timeout.timeout(timeout) {
          loop do
            begin
              return new_socket
            rescue Errno::ECONNREFUSED => e
              $stderr.puts "#{self} caught #{e.message}"
              sleep 0.250
            end
          end
        }
      end

      def new_socket
        @socket = TCPSocket.new(@host, @port)
        @socket.sync = true
        
        @socket
      end

      def connected?
        @socket && !@socket.closed?
      end

      def send_string(str)
        str = <<-HTTP
GET / HTTP/1.1
Host: localhost
Content-Length: #{str.length}

#{str}
HTTP
        p :sending => str
        
        @socket.write str
        @socket.flush
      end
      
      def quit
        send_string({'commandName' => 'quit', 'context' => nil}.to_json)
        read_response
      rescue => e
        p :quit => e.message
      end

      def close
        @socket.close
      end

      def read_response
        raise Error::WebDriverError, "unexpected eof" if @socket.eof?
        line = @socket.gets

        count = 0
        parts = line.split(":", 2)
        
        if parts.first == "Length"
          count = Integer(parts.last.strip)
        end
        
        until line.empty?
          line = @socket.gets.chomp
        end
        
        json_string = @socket.recv(count)
        JSON.parse json_string
        
        # resp     = ""
        # received = ""
        # 
        # p :reading
        # until resp.include?("\n\n")
        #   received = @socket.recv 1
        #   if received
        #     resp += received
        #   end
        # end
        # 
        # p :read => resp
        # 
        # length      = resp.split(":")[1].lstrip!.to_i
        # json_string = @socket.recv length
        # 
        # JSON.parse json_string
      end

    end # ExtensionConnection
  end # Firefox
end # WebDriver
