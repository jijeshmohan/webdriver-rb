module WebDriver
  module Error
    Errors = [
      IndexOutOfBoundsError,
      NoCollectionError,
      NoStringError,
      NoStringLengthError,
      NoStringWrapperError,
      NoSuchDriverError,
      NoSuchElementError,
      NoSuchFrameError,
      NotImplementedError,
      ObsoleteElementError,
      ElementNotDisplayedError,
      ElementNotEnabledError,
      UnhandledError,
      ExpectedError,
      ElementNotSelectedError,
      NoSuchDocumentError,
      UnexpectedJavascriptError,
      NoScriptResultError,
      UnknownScriptResultError,
      NoSuchCollectionError,
      TimeOutError,
      NullPointerError,
      NoSuchWindowError
    ]
  
    class << self
      def for_code(code)
        return if code == 0
      
        Errors[code - 1] || RuntimeError
      end
    end
    
  end 
end 