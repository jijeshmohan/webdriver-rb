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
        Process.kill(9, @pid) if @pid
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
        launch_binary binary_path, "--load-extension=#{wrap_in_quotes_if_neccessary tmp_extension_dir}",
                                   "--user-data-dir=#{wrap_in_quotes_if_neccessary tmp_profile_dir}",
                                   "--activate-on-launch"
      end

      def ext_files
        Dir["#{ext_path}/*"]
      end

      def wrap_in_quotes_if_neccessary(str)
        PLATFORM == :windows ? %{"#{str}"} : str
      end

      def launch_binary(*args)
        case Platform.os
        when :windows
          launch_binary_windows(*args)
        when :unix, :macosx
          @pid = fork { exec(*args) }
        else
          raise "unknown platform"
        end
      end

      def launch_binary_windows(*args)
        if Platform.jruby?
          raise NotImplementedError, "check how java launches the binary"
        else
          require "win32/process"
          @pid = Process.create(:app_name        => args.join(" "),
                                :process_inherit => true,
                                :thread_inherit  => true,
                                :inherit         => true).process_id
        end
      end

      def dll_path
        # TODO: get rid of hardcoded paths
        @dll_path ||= "#{File.dirname(__FILE__)}/../../../../../prebuilt/Win32/Release/npchromedriver.dll"
      end

      def binary_path
        # TODO: get rid of hardcoded paths
        @binary_path ||= "#{ENV['HOME']}\\Local Settings\\Application Data\\Google\\Chrome\\Application\\chrome.exe"
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