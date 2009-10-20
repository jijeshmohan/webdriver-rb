module WebDriver
  module Chrome
   class CommandExecutor
     HEADER = "HTTP/1.1 200 OK\r\nContent-Length: %d\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n%s"
     
     def initialize
       @server       = TCPServer.new("0.0.0.0", 9700)
       @queue        = Queue.new
       @accepted_any = false
       @next_socket  = nil
       
       Thread.new { start_run_loop }
     end

     def execute(command)
       until accepted_any?
         Thread.pass 
         p :passing
         sleep 0.1
       end
       
       json = command.to_json
       data = HEADER % [json.length, json]

       @next_socket.write data
       @next_socket.close
       
       JSON.parse read_response(@queue.pop)
     end
     
     private
     
     def start_run_loop
       loop do
         socket = @server.accept
         @queue << socket
                  
         unless accepted_any?
           read_response socket
           @queue.pop
         end

         @accepted_any ||= true
       end
     end
     
     def read_response(socket)
       result = ''
       
       seen_double_crlf = false
       while !socket.closed? && ((line = socket.gets.chomp) != "EOResponse")
         seen_double_crlf = true if line.empty?
         result << "#{line}\n" if seen_double_crlf
       end
       
       @next_socket = socket
       
       r = result.strip
       p r
       
       r
     end
     
     def accepted_any?
       @accepted_any
     end
     
   end # CommandExecutor
  end # Chrome
end # WebDriver