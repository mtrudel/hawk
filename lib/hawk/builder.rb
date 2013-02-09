require 'tmpdir'
require 'osx/plist'

module Hawk
  module Builder
    module DSL
      def signing_identity(identity)
        @signing_identity = identity
      end
    end

    def app_name
      info_plist_property('CFBundleDisplayName')
    end

    def app_version
      info_plist_property('CFBundleVersion')
    end

    def bundle_identifier
      info_plist_property('CFBundleIdentifier')
    end

    def repo_version
      `git rev-parse --short HEAD`.chomp
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
      @ipa_file
    end

    def build_plist
      ERB.new(File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'manifest.plist.erb'))).result(binding)
    end

    def itms_url
      "itms-services://?action=download-manifest&url=#{plist_url}"
    end

    private

    def app_file
      if (!@app_file)
        output_dir = Dir.tmpdir

        print "Building Xcode project..."
        output = `/usr/bin/xcodebuild CONFIGURATION_BUILD_DIR=#{output_dir} 2>&1`
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
      `/usr/bin/xcodebuild -showBuildSettings | grep "\s#{prop} = "`.gsub!(/.* = /, '').chomp
    end
  end
end
