module WebDriver
  module Platform

    module_function

    def home
      # jruby has an issue with ENV['HOME'] on Windows
      @home ||= Platform.jruby? ? java.lang.System.getProperty('user.home') : ENV['HOME']
    end

    def platform
      @platform ||= case RUBY_PLATFORM
                    when /java/
                      :java
                    when /mswin|msys|mingw32/
                      :windows
                    when /darwin/
                      :macosx
                    when /linux|solaris|bsd/
                      :unix
                    else
                      RUBY_PLATFORM
                    end
    end

    def os
      @os ||= begin
        os = platform()

        if os == :java
          require "java"
          os_name = java.lang.System.getProperty("os.name")
          os = case os_name
                when /windows/i then :windows
                when /mac os/i  then :macosx
                when /linux/i   then :unix
                else                 os_name
                end
        end

        os
      end
    end

    def jruby?
      platform == :java
    end

    def ruby187?
      !!(RUBY_VERSION =~ /^1\.8\.7/)
    end

    def ruby19?
      !!(RUBY_VERSION =~ /^1\.9/)
    end

    def win?
      os == :windows
    end
    alias_method :windows?, :win?



  end # Platform
end # WebDriver

if __FILE__ == $0
  p :platform => WebDriver::Platform.platform,
    :os       => WebDriver::Platform.os,
    :ruby187? => WebDriver::Platform.ruby187?,
    :ruby19?  => WebDriver::Platform.ruby19?,
    :jruby?   => WebDriver::Platform.jruby?,
    :win?     => WebDriver::Platform.win?,
    :home     => WebDriver::Platform.home
end
