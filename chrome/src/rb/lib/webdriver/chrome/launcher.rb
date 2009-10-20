module WebDriver
  module Chrome
    class Launcher
      include FileUtils

      BINARY   = "#{ENV['HOME']}\\Local Settings\\Application Data\\Google\\Chrome\\Application\\chrome.exe"
      EXT_PATH = "#{File.dirname(__FILE__)}/../../../../extension"
      DLL      = "#{File.dirname(__FILE__)}/../../../../../prebuilt/Win32/Release/npchromedriver.dll"

      PLATFORM = case RUBY_PLATFORM
                 when /win32|mingw/
                   :windows
                 when /darwin/
                   :osx
                 else
                   raise "unknown platform"
                 end

      def launch
        copy_extension
        copy_profile
        launch_chrome
      end

      def kill
        Process.kill(9, @pid) if @pid
      end

      private

      def copy_extension
        @temp_extension = "#{ENV['TMP']}/chrome-webdriver/#{object_id}/extension"
        mkdir_p @temp_extension

        ext_files.each { |f| cp f, "#{@temp_extension}/#{File.basename f}" }
        cp DLL, "#{@temp_extension}/"

        if PLATFORM == :windows
          mv "#{@temp_extension}/manifest-win.json", "#{@temp_extension}/manifest.json"
        else
          mv "#{@temp_extension}/manifest-nonwin.json", "#{@temp_extension}/manifest.json"
        end
      end

      def copy_profile
        @temp_profile   = "#{ENV['TMP']}/chrome-webdriver/#{object_id}/profile"
        mkdir_p @temp_profile
        touch "#{@temp_profile}/First Run Dev"
      end

      def launch_chrome
        launch_binary BINARY, "--load-extension=#{wrap_in_quotes_if_neccessary @temp_extension}",
                              "--user-data-dir=#{wrap_in_quotes_if_neccessary @temp_profile}",
                              "--activate-on-launch"
      end

      def ext_files
        Dir[EXT_PATH + "/*"]
      end

      def wrap_in_quotes_if_neccessary(str)
        PLATFORM == :windows ? %{"#{str}"} : str
      end

      def launch_binary(*args)
        case PLATFORM
        when :windows
          require "win32/process"
          @pid = Process.create(
            :app_name        => args.join(" "),
            :process_inherit => true,
            :thread_inherit  => true,
            :inherit         => true
          ).process_id
        when :osx
          @pid = fork { exec(*args) }
        else
          raise "unknown platform"
        end
      end

    end # Launcher
  end # Chrome
end # WebDriver