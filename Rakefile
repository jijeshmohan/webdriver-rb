# Build file for WebDriver. I wonder if this could be run with JRuby?

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

def windows?
  RUBY_PLATFORM.downcase.include?("win32")
end

def mac?
  RUBY_PLATFORM.downcase.include?("darwin")
end

def linux?
  RUBY_PLATFORM.downcase.include?("linux")
end

def all?
  true
end

task :default => [:test]

def present?(arg)
  prefixes = ENV['PATH'].split(File::PATH_SEPARATOR)

  matches = prefixes.select do |prefix|
    File.exists?(prefix + File::SEPARATOR + arg)
  end

  matches.length > 0
end

def python?
  present?("python") || present?("python.exe")
end

def msbuild?
  windows? && present?("msbuild.exe")
end

task :prebuild do
  # Check that common tools are available
  %w(java jar).each do |exe|
    if (!present?(exe) && !present?(exe + ".exe")) then
      puts "Cannot locate '#{exe}' which is required for the build"
      exit -1
    end
  end

  if windows? then
    if (!present?("msbuild.exe")) then
      puts "Cannot locate 'msbuild.exe' which is required for the build"
      exit -1
    end
  end
end

def iPhoneSDKPresent?
  return false # For now
  
  return false unless mac? && present?('xcodebuild')
  begin
    sdks = sh "xcodebuild -showsdks 2>/dev/null", :verbose => false
    !!(sdks =~ /simulator2.2/)
    true
  rescue
    puts "Ouch"
    false
  end
end

# On linux only
$gecko_dev_path = "/usr/lib/xulrunner-devel-1.9.0.10"

task :build => [:prebuild, :common, :htmlunit, :firefox, :jobbie, :safari, :iphone, :support, :remote, :selenium]

task :clean do
  rm_rf 'common/build'
  rm_rf 'htmlunit/build'
  rm_rf 'jobbie/build'
  rm_rf 'jobbie/src/cpp/InternetExplorerDriver/Release'
  rm_rf 'firefox/build'
  rm_rf 'safari/build'
  rm_rf 'iphone/build'
  rm_rf 'support/build'
  rm_rf 'selenium/build'
  rm_rf 'build/'
end

task :test => [:prebuild, :test_htmlunit, :test_firefox, :test_jobbie, :test_safari, :test_iphone, :test_support, :test_remote, :test_selenium] do
end

task :install_firefox => [:firefox] do
  libs = %w(common/build/webdriver-common.jar firefox/build/webdriver-firefox.jar firefox/lib/runtime/json-20080701.jar)

  firefox = "firefox"
  if ENV['firefox'] then
      firefox = ENV['firefox']
  end

  extension_loc = File.dirname(__FILE__) + "/firefox/src/extension"
  extension_loc.tr!("/", "\\") if windows?

  cmd = 'java'
  cmd += ' -cp ' + libs.join(File::PATH_SEPARATOR)
  cmd += ' -Dwebdriver.firefox.development="' + extension_loc + '"'
  cmd += " -Dwebdriver.firefox.bin=\"#{ENV['firefox']}\" " unless ENV['firefox'].nil?
  cmd += ' org.openqa.selenium.firefox.FirefoxLauncher '
  
  sh cmd, :verbose => true
end

common_libs = ["common/lib/runtime/**/*.jar", "common/build/webdriver-common.jar"]
common_test_libs = ["common/lib/**/*.jar", "common/build/webdriver-common.jar", "common/build/webdriver-common-test.jar"]

simple_jars = {
  "common" =>   {
    'src'       => "common/src/java/**/*.java",
    'deps'      => [],
    'jar'       => "common/build/webdriver-common.jar",
    'resources' => nil,
    'classpath' => ["common/lib/runtime/**/*.jar"],
    'test_on'   => false,
  },
  "test_common" => {
    'src'       => "common/test/java/**/*.java",
    'deps'      => [:common],
    'jar'       => "common/build/webdriver-common-test.jar",
    'resources' => nil,
    'classpath' => ["common/lib/**/*.jar", "common/build/webdriver-common.jar"],
    'test_on'   => false,
  },
  "htmlunit" =>   {
    'src'       => "htmlunit/src/java/**/*.java",
    'deps'      => [:common],
    'jar'       => "htmlunit/build/webdriver-htmlunit.jar",
    'resources' => nil,
    'classpath' => ["htmlunit/lib/runtime/**/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_htmlunit" => {
    'src'       => "htmlunit/test/java/**/*.java",
    'deps'      => [:htmlunit, :test_common],
    'jar'       => "htmlunit/build/webdriver-htmlunit-test.jar",
    'resources' => nil,
    'classpath' => ["htmlunit/lib/**/*.jar", "htmlunit/build/webdriver-htmlunit.jar"] + common_test_libs,
    'test_on'   => all?,
  },
  "firefox" =>   {
    'src'       => "firefox/src/java/**/*.java",
    'deps'      => [:common, 'firefox/build/webdriver-extension.zip'],
    'jar'       => "firefox/build/webdriver-firefox.jar",
    'resources' => 'firefox/build/webdriver-extension.zip',
    'classpath' => ["firefox/lib/runtime/**/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_firefox" => {
    'src'       => "firefox/test/java/**/*.java",
    'deps'      => [:firefox, :test_common],
    'jar'       => "firefox/build/webdriver-firefox-test.jar",
    'resources' => nil,
    'classpath' => ["firefox/lib/**/*.jar", "firefox/build/webdriver-firefox.jar"] + common_test_libs,
    'test_on'   => all?,
  },
  "jobbie" =>   {
    'src'       => "jobbie/src/java/**/*.java",
    'deps'      => [:common, 'build/Win32/Release/InternetExplorerDriver.dll'],
    'jar'       => "jobbie/build/webdriver-jobbie.jar",
    'classpath' => ["jobbie/lib/runtime/**/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_jobbie" => {
    'src'       => "jobbie/test/java/**/*.java",
    'deps'      => [:jobbie, :test_common],
    'jar'       => "jobbie/build/webdriver-jobbie-test.jar",
    'resources' => nil,
    'classpath' => ["jobbie/lib/**/*.jar", "jobbie/build/webdriver-jobbie.jar"] + common_test_libs,
    'test_on'   => windows?,
  },
  "remote_common" =>   {
    'src'       => "remote/common/src/java/**/*.java",
    'deps'      => [:common],
    'jar'       => "remote/build/webdriver-remote-common.jar",
    'resources' => nil,
    'classpath' => ["remote/common/lib/runtime/**/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "remote_client" =>   {
    'src'       => "remote/client/src/java/**/*.java",
    'deps'      => [:remote_common],
    'jar'       => "remote/build/webdriver-remote-client.jar",
    'resources' => nil,
    'classpath' => ["remote/common/lib/runtime/**/*.jar", "remote/client/lib/runtime/**/*.jar", "remote/server/lib/runtime/*.jar", "remote/build/webdriver-remote-common.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_remote_client" => {
    'src'       => "remote/client/test/java/**/*.java",
    'deps'      => [:test_common, :firefox, :jobbie, :remote_client, :remote_server],
    'jar'       => "remote/build/webdriver-remote-common-test.jar",
    'resources' => nil,
    'classpath' => ["remote/build/*.jar", "remote/client/lib/**/*.jar", "remote/common/lib/**/*.jar", "firefox/lib/**/*.jar", "firefox/build/webdriver-firefox.jar", "jobbie/build/webdriver-jobbie.jar", "jobbie/lib/runtime/*.jar", "support/build/webdriver-support.jar", "support/lib/runtime/*.jar"] + common_test_libs,
    'test_on'   => all?,
    'test_in'   => 'remote/client',
  },
  "remote_server" => {
    'src'       => "remote/server/src/java/**/*.java",
    'deps'      => [:remote_common, :support],
    'jar'       => "remote/build/webdriver-remote-server.jar",
    'resources' => nil,
    'classpath' => ["remote/common/lib/runtime/**/*.jar", "support/lib/runtime/*.jar", "support/build/webdriver-support.jar", "remote/server/lib/runtime/**/*.jar", "remote/build/webdriver-remote-common.jar"] + common_libs,
    'test_on'   => false,
  },
  "safari" =>   {
    'src'       => "safari/src/java/**/*.java",
    'deps'      => [:common],
    'jar'       => "safari/build/webdriver-safari.jar",
    'resources' => nil,
    'classpath' => ["safari/lib/runtime/**/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_safari" => {
    'src'       => "safari/test/java/**/*.java",
    'deps'      => [:safari, :test_common],
    'jar'       => "safari/build/webdriver-safari-test.jar",
    'resources' => nil,
    'classpath' => ["safari/lib/**/*.jar", "safari/build/webdriver-safari.jar"] + common_test_libs,
    'test_on'   => mac?,
  },
  "iphone_client" =>   {
    'src'       => "iphone/src/java/**/*.java",
    'deps'      => [:common, :remote],
    'jar'       => "iphone/build/webdriver-iphone.jar",
    'resources' => nil,
    'classpath' => ["remote/build/webdriver-remote-client.jar", "remote/build/webdriver-remote-common.jar", "remote/client/lib/runtime/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_iphone_client" => {
    'src'       => "iphone/test/java/**/*.java",
    'deps'      => [:iphone_client, :test_common, :remote_client],
    'jar'       => "iphone/build/webdriver-iphone-test.jar",
    'resources' => nil,
    'classpath' => ["iphone/build/webdriver-iphone.jar", "remote/build/webdriver-remote-client.jar", "remote/build/webdriver-remote-common.jar", "remote/client/lib/runtime/*.jar", "remote/common/lib/runtime/*.jar"] + common_test_libs,
    'test_on'   => iPhoneSDKPresent?,
  },
  "support" =>   {
    'src'       => "support/src/java/**/*.java",
    'deps'      => [:common],
    'jar'       => "support/build/webdriver-support.jar",
    'resources' => nil,
    'classpath' => ["support/lib/runtime/**/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_support" => {
    'src'       => "support/test/java/**/*.java",
    'deps'      => [:support, :test_common],
    'jar'       => "support/build/webdriver-support-test.jar",
    'resources' => nil,
    'classpath' => ["support/lib/**/*.jar", "support/build/webdriver-support.jar"] + common_test_libs,
    'test_on'   => all?,
  },
  "selenium" => {
    'src'       => "selenium/src/java/**/*.java",
    'deps'      => [:common],
    'jar'       => "selenium/build/webdriver-selenium.jar",
    'resources' => nil,
    'classpath' => ["selenium/lib/runtime/**/*.jar"] + common_libs,
    'test_on'   => false,
  },
  "test_selenium" => {
    'src'       => "selenium/test/java/**/*.java",
    'deps'      => [:test_common, :firefox, :jobbie, :htmlunit, :selenium],
    'jar'       => "selenium/build/webdriver-selenium-test.jar",
    'resources' => nil,
    'classpath' => [
                    "selenium/lib/**/*.jar", "selenium/build/webdriver-selenium.jar",
                    "firefox/build/webdriver-firefox.jar", "firefox/lib/**/*.jar",
                    "jobbie/build/webdriver-jobbie.jar", "jobbie/lib/**/*.jar",
                    "htmlunit/build/webdriver-htmlunit.jar", "htmlunit/lib/**/*.jar",
                    "selenium/build/*.jar"
                   ] + common_test_libs,
    'test_on'   => false,
  }
}

simple_jars.each do |name, details|
  file "#{details['jar']}" => FileList[details['src']] + details['deps'] do
   classpath = []
   details['classpath'].each do |path|
     classpath += FileList[path]
   end

    javac :jar => details['jar'],
          :sources => FileList[details['src']],
          :classpath => classpath,
          :resources => details['resources']

    if details['test_on'] then
      root = details['test_in'].nil? ? details['src'].split("/")[0] : details['test_in']
      puts "Root: #{root}"
      junit :in => root, :classpath =>  classpath + [details['jar']]
    end
  end
  task "#{name}" => [details['jar']]
end

task :remote => [:remote_client, :remote_server]
task :test_remote => [:test_remote_client]

file "selenium/build/webdriver-selenium.jar" => FileList["selenium/src/java/org/openqa/selenium/internal/*.js"] do
  sh "jar uf selenium/build/webdriver-selenium.jar -C selenium/src/java org/openqa/selenium/internal/injectableSelenium.js", :verbose => false
  sh "jar uf selenium/build/webdriver-selenium.jar -C selenium/src/java org/openqa/selenium/internal/htmlutils.js", :verbose => false
end

task :test_selenium do
  temp_classpath = simple_jars['test_selenium']['classpath']
  classpath = FileList.new
  temp_classpath.each do |item|
      classpath.add item
  end

  test_string = 'java '
  test_string += '-cp ' + classpath.join(File::PATH_SEPARATOR) + ' '
  test_string += "-Dwebdriver.firefox.bin=\"#{ENV['firefox']}\" " unless ENV['firefox'].nil?
  test_string += 'org.testng.TestNG selenium/test/java/webdriver-selenium-suite.xml'

  result = sh test_string, :verbose => false
end

task :javadocs => [:common, :firefox, :htmlunit, :jobbie, :remote, :safari, :support] do
  mkdir_p "build/javadoc"
   sourcepath = ""
   classpath = "support/lib/runtime/hamcrest-all-1.1.jar"
   %w(common firefox jobbie htmlunit safari support remote/common remote/client).each do |m|
     sourcepath += ":#{m}/src/java"
   end
   cmd = "javadoc -d build/javadoc -sourcepath #{sourcepath} -classpath #{classpath} -subpackages org.openqa.selenium"
  sh cmd
end


#### Internet Explorer ####
file 'build/Win32/Release/InternetExplorerDriver.dll' => FileList['jobbie/src/cpp/**/*.cpp'] do
  msbuild 'WebDriver.sln'
end

file "jobbie/build/webdriver-jobbie.jar" => "build/Win32/Release/InternetExplorerDriver.dll" do
  mkdir_p "jobbie/build/jar/x86"
  mkdir_p "jobbie/build/jar/amd64"
  cp "build/Win32/Release/InternetExplorerDriver.dll", "jobbie/build/jar/x86"
  cp "build/x64/Release/InternetExplorerDriver.dll", "jobbie/build/jar/amd64"
  sh "jar uf jobbie/build/webdriver-jobbie.jar -C jobbie/build/jar .", :verbose => false
end

#### Firefox ####
file 'firefox/build/webdriver-extension.zip' => FileList['firefox/src/extension/**'] + ['firefox/build/extension/components/nsINativeEvents.xpt', 'build/Win32/Release/webdriver-firefox.dll', 'build/linux64/Release/libwebdriver-firefox.so']  do

  if windows?
    mkdir_p "firefox/build/extension/platform/WINNT_x86-msvc/components/"
    cp "build/Win32/Release/webdriver-firefox.dll", "firefox/build/extension/platform/WINNT_x86-msvc/components/"
  end

  cp_r "firefox/src/extension/.", "firefox/build/extension"

  if linux?
    mkdir_p "firefox/build/extension/platform/Linux/components/"
    cp "build/linux64/Release/libwebdriver-firefox.so", "firefox/build/extension/platform/Linux/components/"
  end

  # Delete the .svn dirs
  rm_r Dir.glob("firefox/build/extension/**/.svn")

  if windows? then
    puts "This Firefox JAR is not suitable for uploading to Google Code"
    sh "cd firefox/build/extension && jar cMvf ../webdriver-extension.zip *"
  else
    sh "cd firefox/build/extension && zip -0r ../webdriver-extension.zip * -x \*.svn\*"
  end
end

file 'build/Win32/Release/webdriver-firefox.dll' => FileList['firefox/src/cpp/**/*.cpp'] do
  msbuild 'WebDriver.sln'
end

file "firefox/build/webdriver-firefox.jar" => "build/linux64/Release/x_ignore_nofocus.so" do

  if linux?
    mkdir_p "firefox/build/jar/amd64"
    cp "build/linux64/Release/x_ignore_nofocus.so", "firefox/build/jar/amd64"
  end
  sh "jar uf firefox/build/webdriver-firefox.jar -C firefox/build/jar .", :verbose => false
end

file 'build/linux64/Release/libwebdriver-firefox.so' => FileList['firefox/src/cpp/webdriver-firefox/*.cpp'] + FileList['common/src/cpp/webdriver-interactions/*_linux.cpp'] do
    obj_dir = "build/linux64/objects/ff_ext"
    output_dir = "build/linux64/Release"
    [output_dir, obj_dir].each do |dir|
      mkdir_p dir
    end

    common_files = FileList.new('common/src/cpp/webdriver-interactions/*_linux.cpp')
    #common_files.add 'common/src/cpp/webdriver-interactions/*_linux.cpp'
    common_files.each do |srcfile|
      gccbuild(srcfile, obj_dir)
    end

    firefox_files = FileList.new('firefox/src/cpp/webdriver-firefox/*.cpp')
    firefox_files.each do |srcfile|
      gccbuild_xul(srcfile, obj_dir)
    end

    library_name = 'libwebdriver-firefox.so'
    gcclink(library_name, obj_dir, output_dir)
end

file 'build/linux64/Release/x_ignore_nofocus.so' => FileList['firefox/src/cpp/linux-specific/*.{c,cpp}'] do
    obj_dir = "build/linux64/objects/linux_spec"
    output_dir = "build/linux64/Release"
    [output_dir, obj_dir].each do |dir|
      mkdir_p dir
    end

    linux_specific_files = FileList.new('firefox/src/cpp/linux-specific/*.{c,cpp}')
    linux_specific_files.each do |srcfile|
      gccbuild_c(srcfile, obj_dir)
    end

    library_name = 'x_ignore_nofocus.so'
    gcclink_c(library_name, obj_dir, output_dir)
end

file 'firefox/build/extension/components/nsINativeEvents.xpt' => FileList['firefox/src/cpp/webdriver-firefox/nsINativeEvents.idl'] do
  mkdir_p "firefox/build/extension/components/"
  ff_idl_in = "firefox/src/cpp/webdriver-firefox/nsINativeEvents.idl"
  ff_idl_out = "firefox/build/extension/components/nsINativeEvents.xpt"
  ff_idl_in.tr!("/", "\\") if windows?
  ff_idl_out.tr!("/", "\\") if windows?
  xpt(ff_idl_in, ff_idl_out)
  if linux?
    ff_idl_hdr = ff_idl_in.gsub('.idl', '.h')
    xpt(ff_idl_in, ff_idl_hdr, "header")
  end
end

file 'firefox/build/extension/components/nsIBaseWindow.xpt' => FileList['firefox/src/cpp/webdriver-firefox/nsIBaseWindow.idl'] do
  mkdir_p "firefox/build/extension/components/"
  ff_idl_in = "firefox/src/cpp/webdriver-firefox/nsIBaseWindow.idl"
  ff_idl_out = "firefox/build/extension/components/nsIBaseWindow.xpt"
  ff_idl_in.tr!("/", "\\") if windows?
  ff_idl_out.tr!("/", "\\") if windows?
  xpt(ff_idl_in, ff_idl_out)
  if linux?
    ff_idl_hdr = ff_idl_in.gsub('.idl', '.h')
    xpt(ff_idl_in, ff_idl_hdr, "header")
  end
end

task :test_firefox_py => :test_firefox do
  if python? then
    sh "python py_test.py", :verbose => true
  end
end

task :iphone => [:iphone_server, :iphone_client]
task :test_iphone => [:test_iphone_server, :test_iphone_client, :remote_client]

#### iPhone ####
task :iphone_server => FileList['iphone/src/objc/**'] do
  if iPhoneSDKPresent? then
    puts "Building iWebDriver iphone app"
    sh "cd iphone && xcodebuild -sdk iphonesimulator2.2 ARCHS=i386 -target iWebDriver >/dev/null", :verbose => false
  else
    puts "XCode not found. Not building the iphone driver."
  end
end

# This does not depend on :iphone_server because the dependancy is specified in xcode
task :test_iphone_server do
  if iPhoneSDKPresent? then
    sh "cd iphone && xcodebuild -sdk iphonesimulator2.2 ARCHS=i386 -target Tests"
  else
    puts "XCode not found. Not testing the iphone driver."
  end
end

def version
  `svn info | grep Revision | awk -F: '{print $2}' | tr -d '[:space:]' | tr -d '\n'`
end

task :remote_release => [:remote] do
  mkdir_p "build/dist/remote_client"

  cp 'remote/build/webdriver-remote-client.jar', 'build/dist/remote_client'
  cp 'remote/build/webdriver-remote-common.jar', 'build/dist/remote_client'
  cp 'common/build/webdriver-common.jar', 'build/dist/remote_client'

  cp Dir.glob('remote/common/lib/runtime/*.jar'), 'build/dist/remote_client'
  cp Dir.glob('remote/client/lib/runtime/*.jar'), 'build/dist/remote_client'

  sh "cd build/dist && zip -r webdriver-remote-client-#{version}.zip remote_client/*"
  rm_rf "build/dist/remote_client"

  mkdir_p "build/dist/remote_server"

  cp 'remote/build/webdriver-remote-server.jar', 'build/dist/remote_server'
  cp 'remote/build/webdriver-remote-common.jar', 'build/dist/remote_server'
  cp 'common/build/webdriver-common.jar', 'build/dist/remote_server'

  cp Dir.glob('remote/common/lib/runtime/*.jar'), 'build/dist/remote_server'
  cp Dir.glob('remote/server/lib/runtime/*.jar'), 'build/dist/remote_server'

  rm Dir.glob('build/dist/remote_server/servlet*.jar')

  sh "cd build/dist && zip -r webdriver-remote-server-#{version}.zip remote_server/*"
  rm_rf "build/dist/remote_server"
end

task :release => [:common, :firefox, :htmlunit, :jobbie, :remote_release, :support, :selenium] do
  %w(common firefox jobbie htmlunit support selenium).each do |driver|
    mkdir_p "build/dist/#{driver}"
    cp 'common/build/webdriver-common.jar', "build/dist/#{driver}"
    cp "#{driver}/build/webdriver-#{driver}.jar", "build/dist/#{driver}"
    cp Dir.glob("#{driver}/lib/runtime/*"), "build/dist/#{driver}" if File.exists?("#{driver}/lib/runtime")

    sh "cd build/dist && zip -r webdriver-#{driver}-#{version}.zip #{driver}/*"
    rm_rf "build/dist/#{driver}"
  end
end

task :recomp_idl => FileList['firefox/build/extension/components/nsINativeEvents.xpt', 'firefox/build/extension/components/nsIBaseWindow.xpt'] 

task :all => [:release] do
  mkdir_p "build/all"
  mkdir_p "build/all/webdriver"

  # Expand all the individual webdriver JARs and combine into one
  # We do things this way so that if we've built a JAR on another
  # platform and copied it to the right place, this uberjar works
  %w(common firefox htmlunit jobbie remote-client support selenium).each do |zip|
    sh "pwd", :verbose => true
    sh "cd build/all && unzip -o ../dist/webdriver-#{zip}-#{version}.zip", :verbose => true
  end

  mkdir_p "build/all/all"
  %w(common firefox htmlunit jobbie support selenium).each do |j|
    sh "cd build/all/all && jar xf ../#{j}/webdriver-#{j}.jar"
  end
  sh "cd build/all/all && jar xf ../remote_client/webdriver-remote-client.jar"

  # Repackage the uber jar
  sh "cd build/all/all && jar cf ../webdriver/webdriver-all.jar *"

  # Collect the libraries into one place
  %w(common firefox htmlunit jobbie remote_client support).each do |j|
    cp Dir.glob("build/all/#{j}/*.jar").reject {|f| f =~ /webdriver/} , "build/all/webdriver"
  end

  # And repack. Finally
  sh "cd build/all && zip ../dist/webdriver-all-#{version}.zip webdriver/*"
end

def javac(args)
  # mandatory args
  out = (args[:jar] or raise 'javac: please specify the :jar parameter')
  source_patterns = (args[:sources] or raise 'javac: please specify the :sources parameter')
  sources = FileList.new(source_patterns)
  raise("No source files found at #{sources.join(', ')}") if sources.empty?

  # We'll start with just one thing now
  extra_resources = args[:resources]

  # optional args
  unless args[:exclude].nil?
    args[:exclude].each { |pattern| sources.exclude(pattern) }
  end
  debug = (args[:debug] or true)
  temp_classpath = (args[:classpath]) || []

  classpath = FileList.new
  temp_classpath.each do |item|
    classpath.add item
  end

  target_dir = "#{out}.classes"
  puts target_dir
  unless File.directory?(target_dir) 
	mkdir_p target_dir, :verbose => false 
  end
  
  compile_string = "javac "
  compile_string += "-source 5 -target 5 "
  compile_string += "-g " if debug
  compile_string += "-d #{target_dir} "

  compile_string += "-cp " + classpath.join(File::PATH_SEPARATOR) + " " if classpath.length > 0

  sources.each do |source|
    compile_string += " #{source}"
  end

  sh compile_string, :verbose => false

  # Copy the resource to the target_dir
  if !extra_resources.nil?
    cp_r extra_resources, target_dir, :verbose => false
  end

  jar_string = "jar cf #{out} -C #{target_dir} ."
  sh jar_string, :verbose => false

  rm_rf target_dir, :verbose => false
end

def junit(args)
  using = args[:in]

  source_dir = "#{using}/test/java"
  source_glob = source_dir + File::SEPARATOR + '**' + File::SEPARATOR + '*.java'

  temp_classpath = (args[:classpath]) || []
  classpath = FileList.new
  temp_classpath.each do |item|
      classpath.add item
  end

  tests = FileList.new(source_dir + File::SEPARATOR + '**' + File::SEPARATOR + '*Suite.java')
  tests.exclude '**/Abstract*'

  test_string = 'java '
  test_string += '-cp ' + classpath.join(File::PATH_SEPARATOR) + ' ' if classpath.length > 1
  test_string += '-Djava.library.path=' + args[:native_path].join(File::PATH_SEPARATOR) + ' ' unless args[:native_path].nil?
  test_string += "-Dwebdriver.firefox.bin=\"#{ENV['firefox']}\" " unless ENV['firefox'].nil?
  test_string += 'junit.textui.TestRunner'

  tests.each do |test|
    puts "Looking at #{test}\n"
    name = test.sub("#{source_dir}/", '').gsub('/', '.')
    test_string += " #{name[0, name.size - 5]}"
    result = sh test_string, :verbose => false
  end
end

def msbuild(solution)
  if msbuild?
    sh "MSBuild.exe #{solution} /verbosity:q /target:Rebuild /property:Configuration=Release /property:Platform=x64", :verbose => false
    sh "MSBuild.exe #{solution} /verbosity:q /target:Rebuild /property:Configuration=Release /property:Platform=Win32", :verbose => false
  else
    %w(build/Win32/Release build/x64/Release).each do |dir|
      mkdir_p dir

      %w(InternetExplorerDriver.dll webdriver-firefox.dll).each do |res|
        File.open("#{dir}/#{res}", 'w') {|f| f.write("")}
      end
    end
  end
end

def xpt(idl, output, output_type = "typelib")
  gecko = "third_party\\gecko-1.9.0.11\\"

  if (windows?)
    gecko += "win32"
    cmd = "#{gecko}\\bin\\xpidl.exe -w -m #{output_type} -I#{gecko}\\idl -e #{output} #{idl}"
    sh cmd, :verbose => true
  elsif (linux?)
    sdk_inc = "#{$gecko_dev_path}/sdk/idl"
    sdk_bin = "#{$gecko_dev_path}/bin"
    cmd = "#{sdk_bin}/xpidl -w -m #{output_type} -I#{sdk_inc} -e #{output} #{idl}"
    sh cmd, :verbose => true
  else
    puts "Doing nothing for now. Later revisions will enable xpt building. Creating stub"
    File.open("#{output}", 'w') {|f| f.write("")}
  end
end

$gcc_comp_args = "-fPIC -fshort-wchar"

def gccbuild(cppfile, obj_dir)
  objname = cppfile.split('/')[-1].gsub('.cpp', '.o')
  #puts "g++ #{cppfile} -c -o #{obj_dir}/#{objname}", :verbose => false
  sh "g++ #{cppfile} `pkg-config gtk+-2.0 --cflags` #{$gcc_comp_args} -c -o #{obj_dir}/#{objname}", :verbose => true
end

def gccbuild_c(cfile, obj_dir)
  objname = cfile.split('/')[-1].gsub('.c', '.o')
  sh "gcc #{cfile} #{$gcc_comp_args} -Wall -c -o #{obj_dir}/#{objname}", :verbose => true
end

def gcclink_c(library_name, obj_dir, output_dir)
  sh "gcc -Wall -shared  -fPIC -Os -o #{output_dir}/#{library_name} #{obj_dir}/*.o"
end

def gccbuild_xul(cppfile, obj_dir)
  objname = cppfile.split('/')[-1].gsub('.cpp', '.o')
  include_args = "-I common/src/cpp/webdriver-interactions -I #{$gecko_dev_path}/include -I /usr/include/nspr"

  # XPCOM_GLUE must be defined, so we can use C++ code from within JS.
  # https://developer.mozilla.org/en/XPCOM_Glue
  sh "g++ -DXPCOM_GLUE  -DXPCOM_GLUE_USE_NSPR #{$gcc_comp_args} #{include_args} #{cppfile} -c -o #{obj_dir}/#{objname}", :verbose => true
end


def gcclink(library_name, obj_dir, output_dir)
  gecko_sdk = "#{$gecko_dev_path}/sdk"
  gecko_sdk_libs = "#{gecko_sdk}/lib"
  gecko_sdk_bin = "#{gecko_sdk}/bin"
  # Special care fore linkage should be taken: A frozen linkage is required, as
  # the component does not care for changed interfaces.
  # See: 
  # http://groups.google.com/group/mozilla.dev.tech.xpcom/browse_thread/thread/bd782fa3fd08e0a9
  # https://developer.mozilla.org/en/XPCOM_Glue
  gecko_libs = "-L#{gecko_sdk_libs} -L#{gecko_sdk_bin} -Wl,-rpath-link,#{gecko_sdk_bin} -lxpcomglue_s -lxpcom -lnspr4 -lrt"
  gtk_libs = "`pkg-config gtk+-2.0 --libs`"
  #gtk_libs = ""
  # -fPIC is important - all of the code should be position independent.
  gcc_link_flags = "-fno-rtti -fno-exceptions -shared  -fPIC"
  sh "g++ -Wall -Os -o #{output_dir}/#{library_name} #{obj_dir}/*.o #{gecko_libs} #{gtk_libs} #{gcc_link_flags} "
end
