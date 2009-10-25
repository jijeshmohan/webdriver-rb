require "pp"

module WebDriver
  module Firefox
    class Binary
      def initialize
        ENV['MOZ_NO_REMOTE'] = '1' # able to launch multiple instances
        check_binary_exists
      end
      
      def create_base_profile(name)
        out = `#{path} --verbose -CreateProfile #{name} 2>&1` # windows? 
        unless $?.success?
          raise Error::WebDriverError, "could not create base profile: (#{$?.exitstatus})\n#{out}"
        end
      end
      
      def start_with(profile)
        ENV['XRE_PROFILE_PATH'] = profile.directory

        if Platform.os == :unix
          # TODO: native events
          # if (isOnLinux()
          #     && (profile.enableNativeEvents() || profile.alwaysLoadNoFocusLib())) {
          #   modifyLinkLibraryPath(profile);
          # }
        end
        
        execute
      end
      
      def execute
        args = [path, "-no-remote", "--verbose"]
        @pid = fork do
          STDOUT.reopen("firefox-binary-out.stdout")
          STDERR.reopen("firefox-binary-out.stderr")
          exec(*args)
        end # TODO: windows/jruby
      end
      
      def kill
        # TODO: windows/jruby
        Process.kill("TERM", @pid) if @pid
      end
      
      def wait
        Process.waitpid @pid
      end
      
      private
      
      def path
        @path ||=  case Platform.os
                          when :macosx
                            "/Applications/Firefox.app/Contents/MacOS/firefox-bin"
                          when :windows
                            windows_path
                          when :unix
                            "/usr/bin/firefox"
                          else          
                            raise "Unknown platform: #{Platform.os}"
                          end
      end
      
      def check_binary_exists
        unless File.file?(path)
          raise Error::WebDriverError, "Could not find Firefox binary. Make sure Firefox is installed (OS: #{Platform.os})"
        end
      end
      
      def windows_path
        windows_registry_path || "#{ENV['PROGRAMFILES'] || "\\Program Files"}\\Mozilla Firefox\\firefox.exe"
      end
      
      def windows_registry_path
        require "win32/registry"
        
        lm = Win32::Registry::HKEY_LOCAL_MACHINE
        lm.open("SOFTWARE\\Mozilla\\Mozilla Firefox") do |reg|
          main = lm.open("SOFTWARE\\Mozilla\\Mozilla Firefox\\#{reg.keys[0]}\\Main")
          if entry = main.find {|key, type, data| key =~ /pathtoexe/i}
            return entry.last
          end
        end
      end
      
      def tmp_dir(name)
        Dir.mktmpdir(name)
      end
      
    end # Binary
  end # Firefox
end # WebDriver