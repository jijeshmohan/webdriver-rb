module WebDriver
  module Firefox
    class Bridge
      
      def initialize
        @launcher   = Launcher.new(Binary.new).launch
        @connection = @launcher.connection
        @context    = newSession
      end
      
      def quit
        @connection.quit
      end
      
      private
      
      def newSession
        execute :newSession
      end
      
      def execute(*args)
        p :excuting => args
        raw_execute(*args)['response']
      end
      
      def raw_execute(command, opts = {})
        request = {:commandName => command, :context => @context}
        
        if eid = opts[:element_id]
          request[:elementId] = eid
        end
        
        if params = opts[:params]
          request[:parameters] = params
        end
        

        @connection.send_string request.to_json
        resp = @connection.read_response
        
        if resp['isError']
          raise Error::WebDriverError, resp['value'] || resp.inspect
        end
        
        resp
      end
      
    end # Bridge
  end # Firefox
end # WebDriver