module WebDriver
  module Firefox
    class Profile

      ANONYMOUS_PROFILE_NAME = "WEBDRIVER_ANONYMOUS_PROFILE"
      EXTENSION_NAME         = "fxdriver@googlecode.com"
      EM_NAMESPACE_URI       = "http://www.mozilla.org/2004/em-rdf#"

      # TODO: hardcoded path
      DEFAULT_EXTENSION_SOURCE = File.expand_path("#{File.dirname(__FILE__)}/../../../../extension")

      attr_reader :name, :port, :directory

      def initialize(name = ANONYMOUS_PROFILE_NAME, port = Launcher::DEFAULT_PORT, opts = {})
        @name             = name
        @port             = port
        @extension_source = opts[:extension_source] || DEFAULT_EXTENSION_SOURCE

        if @name == ANONYMOUS_PROFILE_NAME
          create_anonymous_profile opts[:template_profile]
          refresh_ini
        else
          raise NotImplementedError
          add_extension(true)
        end

        # TODO: native events, loadNoFocusLib?
        # unless File.directory?(directory)
        #   raise Error::WebDriverError, "profile dir does not exist: #{profile_dir.inspect}"
        # end
      end

      private

      def create_anonymous_profile(template)
        @directory = Dir.mktmpdir("webdriver-profile")

        if template && File.directory?(template)
          copy_profile_from(template_profile)
        end

        update_user_prefs
        add_extension
      end

      def add_extension(force = false)
        ext_path = File.join(extensions_dir, EXTENSION_NAME)

        if File.exists?(ext_path)
          return unless force
        end
        FileUtils.rm_rf ext_path
        FileUtils.mkdir_p File.dirname(ext_path), :mode => 0700

        # FIXME: don't use ditto :)
        FileUtils.cp_r @extension_source, ext_path
      end

      def copy_profile_from(source)
        FileUtils.cp_r(source, directory, :verbose => true)
      end

      def extensions_dir
        @extensions_dir ||= File.join(directory, "extensions")
      end

      def user_prefs_path
        @user_prefs_js ||= File.join(directory, "user.js")
      end

      def refresh_ini

      end

      def update_user_prefs
        prefs = existing_user_prefs.merge DEFAULT_PREFERENCES
        prefs['webdriver.firefox_port'] = @port

        write_prefs prefs
      end

      def existing_user_prefs
        if File.exist?(user_prefs_path)
          prefs_string = File.read(user_prefs_path)
          raise NotImplementedError
        else
          {}
        end
      end

      def write_prefs(prefs)
        File.open(user_prefs_path, "w") do |file|
          prefs.each do |key, value|
            file.puts "user_pref(#{key.inspect}, #{value});"
          end
        end
      end

      DEFAULT_PREFERENCES = {
        "app.update.auto"                           => 'false',
        "app.update.enabled"                        => 'false',
        "browser.download.manager.showWhenStarting" => 'false',
        "browser.EULA.override"                     => 'true',
        "browser.EULA.3.accepted"                   => 'true',
        "browser.link.open_external"                => '2',
        "browser.link.open_newwindow"               => '2',
        "browser.safebrowsing.enabled"              => 'false',
        "browser.search.update"                     => 'false',
        "browser.sessionstore.resume_from_crash"    => 'false',
        "browser.shell.checkDefaultBrowser"         => 'false',
        "browser.startup.page"                      => '0',
        "browser.tabs.warnOnClose"                  => 'false',
        "browser.tabs.warnOnOpen"                   => 'false',
        "dom.disable_open_during_load"              => 'false',
        "extensions.update.enabled"                 => 'false',
        "extensions.update.notifyUser"              => 'false',
        "security.warn_entering_secure"             => 'false',
        "security.warn_submit_insecure"             => 'false',
        "security.warn_entering_secure.show_once"   => 'false',
        "security.warn_entering_weak"               => 'false',
        "security.warn_entering_weak.show_once"     => 'false',
        "security.warn_leaving_secure"              => 'false',
        "security.warn_leaving_secure.show_once"    => 'false',
        "security.warn_submit_insecure"             => 'false',
        "security.warn_viewing_mixed"               => 'false',
        "security.warn_viewing_mixed.show_once"     => 'false',
        "signon.rememberSignons"                    => 'false',
        "startup.homepage_welcome_url"              => '"about:blank"',
        "javascript.options.showInConsole"          => 'true',
        "browser.dom.window.dump.enabled"           => 'true'
      }

    end # Profile
  end # Firefox
end # WebDriver