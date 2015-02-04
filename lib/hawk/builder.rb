require 'tmpdir'
require 'fileutils'
require 'osx/plist'

module Hawk
  module Builder
    module DSL
      def signing_identity(identity)
        @signing_identity = identity
      end

      def project(project)
        @project = project
      end

      def workspace(workspace)
        @workspace = workspace
      end

      def scheme(scheme)
        @scheme = scheme
      end

      def configuration(configuration)
        @configuration = configuration
      end

      def bundle_id_fix(fix)
        @bundle_id_fix = fix
      end

      def vendor_name(name)
        @vendor_name = name
      end

      def icon_path(path)
        @icon_path = path
      end

      def fullsize_image_path(path)
        @fullsize_image_path = path
      end
    end

    def app_name
      info_plist_property('CFBundleDisplayName')
    end

    def app_version
      info_plist_property('CFBundleVersion')
    end

    def bundle_identifier
      if @bundle_id_fix
        info_plist_property('CFBundleIdentifier') + '.ios8fix'
      else
        info_plist_property('CFBundleIdentifier')
      end
    end

    def repo_version
      `git rev-parse --short HEAD`.chomp
    end

    def vendor_name
      @vendor_name
    end

    def icon_path
      @icon_path
    end

    def escaped_icon_url
      (icon_path)? CGI.escapeHTML(icon_url) : 'https://raw.githubusercontent.com/mtrudel/hawk/master/templates/icon.png'
    end

    def fullsize_image_path
      @fullsize_image_path
    end

    def escaped_fullsize_image_url
      (fullsize_image_path)? CGI.escapeHTML(fullsize_image_url) : 'https://raw.githubusercontent.com/mtrudel/hawk/master/templates/fullsize_image.png'
    end

    def ipa_file
      if (!@ipa_file)
        output_dir = Dir.tmpdir
        product_name = project_property('PRODUCT_NAME')
        @ipa_file = File.join(output_dir, "#{product_name}.ipa")

        the_app_file = app_file # Do this before below so output happens in the right order

        print "Signing app..."
        output = `/usr/bin/xcrun -sdk iphoneos PackageApplication -v -s "#{@signing_identity || "iPhone Distribution"}" -o #{@ipa_file} #{the_app_file} 2>&1`
        if $?.to_i != 0
          puts "error (text follows)"
          abort output
        end
        puts "done"
      end
      FileUtils.copy(@ipa_file, Dir.pwd) if @options[:preserve_ipa]
      @ipa_file
    end

    def build_plist
      ERB.new(File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'manifest.plist.erb'))).result(binding)
    end

    def itms_url
      "itms-services://?#{URI.encode_www_form(:action => "download-manifest", :url => plist_url)}"
    end

    def escaped_ipa_url
      CGI.escapeHTML(ipa_url)
    end

    def build_webpage
      ERB.new(File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'install.html.erb'))).result(binding)
    end

    private

    def app_file
      if (!@app_file)
        output_dir = Dir.tmpdir

        print "Building Xcode project..."
        output = `#{xcode_command} CONFIGURATION_BUILD_DIR=#{output_dir} 2>&1`

        if $?.to_i != 0
          puts "error (text follows)"
          abort output
        end
        puts "done"
        @app_file = File.join(output_dir, project_property('FULL_PRODUCT_NAME'))
      end
      @app_file
    end

    def info_plist_property(prop)
      plist_file = File.join(File.dirname(app_file), project_property('INFOPLIST_PATH'))
      result = OSX::PropertyList.load_file(plist_file)[prop]
    end

    def project_property(prop)
      `#{xcode_command} -showBuildSettings | grep "\s#{prop} = " 2>&1`.gsub!(/.* = /, '').chomp
    end

    def xcode_command
      options = []
      options << "-project #{@project}" if @project
      options << "-workspace #{@workspace}" if @workspace
      options << "-scheme #{@scheme}" if @scheme
      options << "-configuration #{@configuration || 'Release'}"
      "/usr/bin/xcodebuild #{options.join(' ')}"
    end
  end
end
