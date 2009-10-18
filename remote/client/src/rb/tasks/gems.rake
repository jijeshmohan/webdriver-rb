namespace :gems do

  def gem_version
    @gem_version ||= File.read("pom.xml").match(%r{<version>([\d\.]+).*?</version>})[1]
  end

  def build_gem(name, opts={})
    # creates an init script for the gem that sets up classpath entries
    if opts[:classpath]
      mkdir "build/pkg/#{name}/lib"
      classpath_script = <<-RUBY
      WebDriver::Server.classpath += Dir[File.join(File.dirname(__FILE__), "..", "java", "*.jar")].collect { |f| File.expand_path(f) }
      RUBY
      File.open("build/pkg/#{name}/lib/#{name}.rb", "w") { |f| f.write classpath_script }
    end

    # need to read the version number before doing a chdir
    gem_version

    Dir.chdir("build/pkg/#{name}") do
      spec = Gem::Specification.new do |s|
        s.name = name
        s.version = gem_version
        s.summary = "A developer focused tool for automated testing of webapps"
        s.authors = ["Simon M. Stewart"]
        s.email = "webdriver@googlegroups.com"
        s.homepage = "http://webdriver.googlecode.com/"
        s.rubyforge_project = "web_driver"
        yield s if block_given?
      end
      builder = Gem::Builder.new(spec)
      builder.build
    end
  end

  desc "Build the remote client gem."
  task :client do
    rm_rf "build/pkg/web_driver"
    mkdir_p "build/pkg/web_driver/lib"
    cp_r FileList["remote/ruby/lib/**"], "build/pkg/web_driver/lib"

    # ugly hack to load the server and driver gems for classpath setup when WebDriver::Server is autoloaded
    load_script = <<-RUBY
      # attempt to load all the available drivers for classpath setup.  doesn't really belong here...
      %w(server firefox htmlunit).each do |driver|
        require "web_driver-\#{driver}" rescue LoadError
      end
    RUBY
    File.open("build/pkg/web_driver/lib/web_driver/server.rb", "a") { |f| f.write(load_script) }

    build_gem("web_driver") do |s|
      s.files = FileList["lib/**/*.rb"]
      s.add_runtime_dependency("json")
      s.has_rdoc = true
    end
  end

  desc "Build the remote server gem."
  task :server => [:remote_server] do
    rm_rf "build/pkg/web_driver-server"
    mkdir_p "build/pkg/web_driver-server/java"

    cp FileList[%W{
      remote/build/*.jar
      remote/server/lib/**/*.jar
      remote/common/lib/**/*.jar
      common/lib/**/*.jar
      common/build/webdriver-common.jar
    }], "build/pkg/web_driver-server/java"

    build_gem("web_driver-server", :classpath => true) do |s|
      s.files = FileList["lib/**", "java/*.jar"]
      s.add_runtime_dependency("web_driver")
    end
  end

  namespace :driver do

    desc "Build the firefox driver gem."
    task :firefox => [:"rake:firefox"] do
      rm_rf "build/pkg/web_driver-firefox"
      mkdir_p "build/pkg/web_driver-firefox/java"

      cp FileList[%W{
        firefox/lib/**/*.jar
        firefox/build/webdriver-firefox.jar
      }], "build/pkg/web_driver-firefox/java"

      cp_r FileList["firefox/src/extension"], "build/pkg/web_driver-firefox"

      # TODO: add a "install firefox extension" binary script

      build_gem("web_driver-firefox", :classpath => true) do |s|
        s.files = FileList["lib/**", "java/**", "extension/**"]
        s.add_runtime_dependency("web_driver-server")
      end
    end

    desc "Build the htmlunit driver gem."
    task :htmlunit => [:"rake:htmlunit"] do
      rm_rf "build/pkg/web_driver-htmlunit"
      mkdir_p "build/pkg/web_driver-htmlunit/java"

      cp FileList[%W{
        htmlunit/lib/**/*.jar
        htmlunit/build/webdriver-htmlunit.jar
      }], "build/pkg/web_driver-htmlunit/java"

      build_gem("web_driver-htmlunit", :classpath => true) do |s|
        s.files = FileList["lib/**", "java/**"]
        s.add_runtime_dependency("web_driver-server")
      end
    end

    task :all => [:firefox, :htmlunit]

  end

  task :all => [:client, :server, :"driver:all"]

end

desc "Build all available gems."
task :gems => [:"gems:all"]
