module WebDriver
  module Chrome
    class Launcher
      include FileUtils

      attr_reader :pid

      def launch
        create_extension
        create_profile
        launch_chrome

        pid
      end

      def kill
        if Platform.jruby?
          @process.destroy if @process
        else
          Process.kill(9, @pid) if @pid
        end
      end

      private

      def create_extension
        ext_files.each { |file| cp file, tmp_extension_dir }
        cp dll_path, tmp_extension_dir

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

      def launch_binary(*args)
        puts "starting chrome: #{args.inspect}"

        if Platform.jruby?
          launch_binary_jruby(*args)
        end

        case Platform.os
        when :windows
          launch_binary_windows(*args)
        when :unix, :macosx
          launch_binary_unix
        else
          raise "unknown platform"
        end
      end

      def launch_binary_windows(*args)
        require "win32/process"
        @pid = Process.create(:app_name        => args.join(" "),
                              :process_inherit => true,
                              :thread_inherit  => true,
                              :inherit         => true).process_id
      end

      def launch_binary_jruby(*args)
        @process = java.lang.Runtime.getRuntime.exec args.join(" ")
        # @thread = Thread.new { system(args) || raise("unable to launch Chrome: #{args.inspect}") }
      end

      def launch_binary_unix(*args)
        @pid = fork { exec(*args) }
      end

      def dll_path
        # TODO: get rid of hardcoded paths
        @dll_path ||= "#{File.dirname(__FILE__)}/../../../../../prebuilt/Win32/Release/npchromedriver.dll"
      end

      def binary_path
        # TODO: get rid of hardcoded paths
        @binary_path ||= "#{Platform.home}\\Local Settings\\Application Data\\Google\\Chrome\\Application\\chrome.exe"
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

    end # Launcher
  end # Chrome
end # WebDriver