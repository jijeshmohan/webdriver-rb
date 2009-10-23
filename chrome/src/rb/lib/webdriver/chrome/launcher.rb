module WebDriver
  module Chrome
    class Launcher
      include FileUtils

      attr_reader :pid

      def self.launcher
        launcher =  case Platform.os
                    when :windows
                      WindowsLauncher.new
                    when :macosx
                      MacOSXLauncher.new
                    when :unix
                      UnixLauncher.new
                    else
                      raise "unknown OS: #{Platform.os}"
                    end

        launcher.extend(JRubyLaunchDecorator) if Platform.jruby?
        launcher
      end

      def launch
        create_extension
        create_profile
        launch_chrome

        pid
      end

      def kill
        Process.kill(9, @pid) if @pid
      end

      private

      def create_extension
        ext_files.each { |file| cp file, tmp_extension_dir }
        cp linked_lib_path, tmp_extension_dir

        if Platform.win?
          mv "#{tmp_extension_dir}/manifest-win.json", "#{tmp_extension_dir}/manifest.json"
        else
          mv "#{tmp_extension_dir}/manifest-nonwin.json", "#{tmp_extension_dir}/manifest.json"
        end
      end

      def create_profile
        touch "#{tmp_profile_dir}/First Run Dev"
      end

      def launch_chrome
        launch_binary wrap_in_quotes_if_neccessary(binary_path),
                      "--load-extension=#{wrap_in_quotes_if_neccessary tmp_extension_dir}",
                      "--user-data-dir=#{wrap_in_quotes_if_neccessary tmp_profile_dir}",
                      "--activate-on-launch"
      end

      def ext_files
        Dir["#{ext_path}/*"]
      end

      def wrap_in_quotes_if_neccessary(str)
        Platform.win? ? %{"#{str}"} : str
      end

      def ext_path
        # TODO: get rid of hardcoded paths
        @ext_path ||= "#{File.dirname(__FILE__)}/../../../../extension"
      end

      def tmp_extension_dir
        @tmp_extension_dir ||= Dir.mktmpdir("webdriver-chrome-extension")
      end

      def tmp_profile_dir
        @tmp_profile_dir ||= Dir.mktmpdir("webdriver-chrome-profile")
      end

      module JRubyLaunchDecorator
        def launch_binary(*args)
          @process = java.lang.Runtime.getRuntime.exec args.join(" ")
        end

        def kill
          @process.destroy if @process
        end
      end

      class WindowsLauncher < Launcher
        def linked_lib_path
          # TODO: get rid of hardcoded paths
          @linked_lib_path ||= "#{File.dirname(__FILE__)}/../../../../../prebuilt/Win32/Release/npchromedriver.dll"
        end

        def binary_path
          @binary_path ||= "#{Platform.home}\\Local Settings\\Application Data\\Google\\Chrome\\Application\\chrome.exe"
        end

        def launch_binary(*args)
          require "win32/process"
          @pid = Process.create(:app_name        => args.join(" "),
                                :process_inherit => true,
                                :thread_inherit  => true,
                                :inherit         => true).process_id
        end
      end

      class UnixLauncher < Launcher
        def launch_binary(*args)
          @pid = fork { exec(*args) }
        end
        
        def linked_lib_path
          # TODO: get rid of hardcoded paths
          @linked_lib_path ||= "#{File.dirname(__FILE__)}/../../../../../prebuilt/Win32/Release/npchromedriver.dll"
        end

        def binary_path
          @binary_path ||= "/usr/bin/google-chrome"
        end
        
      end

      class MacOSXLauncher < UnixLauncher
        def binary_path
          @binary_path ||= "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        end
        
      end

    end # Launcher
  end # Chrome
end # WebDriver