require 'aws/s3'
require 'googl'

module Hawk
  module S3Uploader
    module DSL
      def access_key_id(key)
        @access_key_id = key
      end

      def secret_access_key(key)
        @secret_access_key = key
      end

      def bucket_name(name)
        @bucket_name = name
      end

      def delete_after(days)
        @delete_after = days
      end
    end

    def ipa_url
      if (!@ipa_url)
        file = ipa_file
        @ipa_url = object(File.basename(file)) do |obj|
          print "Uploading #{File.basename(file)} to S3..."
          obj.write(Pathname.new(file), :content_type => 'application/octet-stream')
          puts 'done'
        end
      end
      @ipa_url
    end

    def plist_url
      if (!@plist_url) 
        @plist_url = object('manifest.plist') do |obj|
          plist_data = build_plist
          print 'Uploading plist to S3...'
          obj.write(plist_data, :content_type => 'application/xml')
          puts 'done'
        end
      end
      @plist_url
    end

    def webpage_url
      if (!@webpage_url) 
        @webpage_url = object('install.html') do |obj|
          webpage_data = build_webpage
          print 'Uploading install page to S3...'
          obj.write(webpage_data, :content_type => 'text/html')
          puts 'done'
        end
        @webpage_url = Googl.shorten(@webpage_url).short_url
      end
      @webpage_url
    end

    private

    def object(name, &block)
      prefix = "#{app_name}/#{app_version}/"
      if !@bucket
        @s3 ||= AWS::S3.new(:access_key_id => @access_key_id, :secret_access_key => @secret_access_key)
        @bucket = @s3.buckets.create @bucket_name
        @bucket.lifecycle_configuration.update do
          remove_rule prefix
          add_rule prefix, :id => prefix, :expiration_time => (@delete_after || 30)
        end
      end
      obj = @bucket.objects["#{prefix}#{name}"]
      yield obj
      obj.url_for(:read, :expires => 86400 * (@delete_after || 30)).to_s
    end
  end
end
