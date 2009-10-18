# Syntax sugar for the WebDriver API.

require "webdriver"

module WebDriver::Remote

  # @api private
  class IndexedAccessorProxy

    def initialize(delegate, read_method)
      @delegate = delegate
      @read_method = read_method
    end

    def [](index)
      raise ArgumentError, "must supply a valid index" unless index
      @delegate.send @read_method, index
    end

  end

  class Element

    alias_method :one, :find_element
    alias_method :first, :find_element
    alias_method :all, :find_elements

    alias_method :attribute_without_index, :attribute
    def attribute(name = nil)
      if name
        attribute_without_index(name)
      else
        @attribute ||= IndexedAccessorProxy.new(self, :attribute_without_index)
      end
    end

    def [](name)
      attribute_without_index(name)
    end

    alias_method :style_without_index, :style
    def style(property_name = nil)
      if property_name
        style_without_index(property_name)
      else
        @style ||= IndexedAccessorProxy.new(self, :style_without_index)
      end
    end

  end

  class Driver

    alias_method :one, :find_element
    alias_method :first, :find_element
    alias_method :all, :find_elements

    # Opens the specified URL in the browser.
    def get(url)
      navigate.to(url)
    end

    alias_method :script, :execute_script

    # Syntax sugar for finding one element by id.
    # @see #find_element
    def [](id)
      find_element(:id, id)
    end

  end

end
