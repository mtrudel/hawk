require 'aws/s3'

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
    end

    def ipa_url
      if (!@ipa_url)
        file = ipa_file
        @ipa_url = object(File.basename(file)) do |obj|
          print "Uploading #{File.basename(file)} to S3..."
          obj.write(Pathname.new(file))
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

    private

    def object(name, &block)
      s3 = AWS::S3.new(:access_key_id => @access_key_id, :secret_access_key => @secret_access_key)
      bucket = s3.buckets.create @bucket_name
      obj = bucket.objects[name]
      yield obj
      obj.acl = :public_read
      obj.public_url
    end
  end
end
