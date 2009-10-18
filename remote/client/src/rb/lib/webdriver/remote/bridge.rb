require "json"
require "net/http"
require "uri"

module WebDriver
  module Remote

    DEBUG = $VERBOSE == true

    #
    # Low level bridge to the remote server, through which the rest of the API works.
    # 
    # @api private
    #

    class Bridge

      CONTENT_TYPE_JSON = "application/json"

      attr_accessor :context

      #
      # Initializes the bridge with the given server URL.
      #
      # @param server_url [String] base URL for all commands.  Note that a trailing '/' is very important!
      #

      def initialize(server_url)
        @server_url = URI.parse(server_url)
        @context    = "context"
      end

      def create_session
        resp        = new_session()
        @session_id = resp.session_id

        Capabilities.json_create resp.value
      end

      #
      # Returns the current session ID.
      #

      def session_id
        @session_id || raise(StandardError, "no current session exists")
      end

      def switch_to_active_element
        ids = get_active_element.value
        if ids.empty?
          nil
        else
          Element.new(self, ids[0])
        end

      end

      protected

      #
      # Defines a wrapper method for a command, which ultimately calls #invoke.
      #
      # @param name [Symbol]
      #   name of the resulting method
      # @param url [String]
      #   a URL template, which can include some arguments, much like the definitions on the server.
      #   the :session_id and :context parameters are implicitly handled, but the remainder will become
      #   required method arguments.
      #   e.g., "session/:session_id/:context/element/:id/text" will define a method that takes id
      #   as it's first argument.
      # @param verb [Symbol]
      #   the appropriate http verb, such as :get, :post, or :delete
      #

      def self.command(name, verb, url)
        # get method arguments from the url (but never session_id and context)
        args = url.scan(/:(\w+)/).flatten - %w(session_id context)
        # convert url arguments to use string interpolation
        url = url.gsub(/:(\w+)/) { "\#{#{$1}}" }

        # post also commands accept an argument list which becomes the payload
        if verb == :post
          args << "*args"
          optional = ", args"
        end

        #
        # define a wrapper method.  the result should be such that:
        #
        # command :send_keys, "session/:session_id/:context/element/:id/value", :post
        #
        # creates:
        #
        # def send_keys(id, *args)
        #   invoke(:post, "session/#{session_id}/#{context}/element/#{id}/value", args)
        # end
        #
        #

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}(#{args.join(", ")})
          invoke(#{verb.inspect}, "#{url}"#{optional})
        end
        RUBY
      end

      #
      # Invokes a command on the remote server via the REST / JSON API.
      #
      # @param verb [Symbol] one of :get, :post, :delete, etc.
      # @param url [String] path portion of the url to access
      # @param args [Array] array of arguments to the remote server when using POST or PUT
      #
      # @return [Response] the server response, if any; otherwise nil
      #
      # @raise Remote::Error if there is an error invoking the command
      #

      def invoke(verb, url, args = nil)
        puts "-> #{verb.to_s.upcase} #{url}" if DEBUG

        # determine the appropriate headers, url, and payload
        response = nil
        url      = @server_url.merge(url) unless url.kind_of?(URI)
        headers  = { "Accept" => CONTENT_TYPE_JSON }

        if args
          headers.merge!({ "Content-Type" => CONTENT_TYPE_JSON + "; charset=utf-8" })
          args = args.to_json
          puts "  >>> #{args}" if DEBUG
        end

        # n.b.: assuming the host and port don't change, and am ignoring SSL for now
        @http ||= Net::HTTP.new(url.host, url.port)

        @http.request(Net::HTTP.const_get(verb.to_s.capitalize).new(url.path, headers), args) do |res|
          response = case res
          when Net::HTTPRedirection
            # TODO: should be checking against a maximum redirect count
            verb = :get
            url = URI.parse(res["Location"])
            args = nil
            raise RetryException
          when Net::HTTPNoContent
            nil
          when Net::HTTPSuccess
            # construct the response object
            puts "<- #{res.body}\n" if DEBUG
            case res.content_type
            when CONTENT_TYPE_JSON
              data = JSON.parse(res.body)
              raise ServerError.json_create(data) if data["error"]
              Response.json_create(data)
            else
              raise RuntimeError, "unexpected response content type: #{res.content_type}"
            end
          else
            puts "<- #{res.body}\n" if DEBUG
            if res.content_type == CONTENT_TYPE_JSON
              raise ServerError.json_create(JSON.parse(res.body))
            else
              raise RuntimeError, "status code: #{res.code}, body: #{res.body}"
            end
          end
        end

        response
      rescue RetryException
        retry
      end

    end # Bridge
  end # Remote
end # WebDriver
