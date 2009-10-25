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

      def getPageSource
        execute :getPageSource
      end

      def get(url)
        execute :get, :parameters => [url]
      end

      def close
        execute :close
      # TODO: rescue ?
      end

      def getCurrentUrl
        execute :getCurrentUrl
      end

      def getTitle
        execute :title
      end

      #
      # Finders - TODO: should be shared with Chrome::Bridge
      #

      def findElementByClassName(parent, class_name)
        find_element_by 'class name', class_name, parent
      end

      def findElementsByClassName(parent, class_name)
        find_elements_by 'class name', class_name, parent
      end

      def findElementById(parent, id)
        find_element_by 'id', id, parent
      end

      def findElementsById(parent, id)
        find_elements_by 'id', id, parent
      end

      def findElementByLinkText(parent, link_text)
        find_element_by 'link text', link_text, parent
      end

      def findElementsByLinkText(parent, link_text)
        find_elements_by 'link text', link_text, parent
      end

      def findElementByPartialLinkText(parent, link_text)
        find_element_by 'partial link text', link_text, parent
      end

      def findElementsByPartialLinkText(parent, link_text)
        find_elements_by 'partial link text', link_text, parent
      end

      def findElementByName(parent, name)
        find_element_by 'name', name, parent
      end

      def findElementsByName(parent, name)
        find_elements_by 'name', name, parent
      end

      def findElementByTagName(parent, tag_name)
        find_element_by 'tag name', tag_name, parent
      end

      def findElementsByTagName(parent, tag_name)
        find_elements_by 'tag name', tag_name, parent
      end

      def findElementByXpath(parent, xpath)
        find_element_by 'xpath', xpath, parent
      end

      def findElementsByXpath(parent, xpath)
        find_elements_by 'xpath', xpath, parent
      end


      private

      def find_element_by(how, what, parent = nil)
        if parent
          id = execute :findChildElement,
                       :parameters => [{:id => parent, :using => how, :value => what}]
        else
          id = execute :findElement, :parameters => [how, what]
        end

        Element.new self, element_id_from(id)
      end

      def find_elements_by(how, what, parent = nil)
        if parent
          ids = execute :findChildElements,
                        :parameters => [{:id => parent, :using => how, :value => what}]
        else
          ids = execute :findElements, :parameters => [how, what]
        end

        ids.map { |id| Element.new self, element_id_from(id) }
      end

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

        if ctx = resp['context']
          @context = ctx
        end

        resp
      end

      # TODO: shared with chrome bridge
      def element_id_from(arr)
        arr.to_s.split("/").last
      end


    end # Bridge
  end # Firefox
end # WebDriver