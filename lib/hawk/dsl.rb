require 'hawk/builder'
require 'hawk/s3_uploader'
require 'hawk/notifier'

module Hawk
  class DSL
    include Hawk::Builder::DSL
    include Hawk::S3Uploader::DSL
    include Hawk::Notifier::DSL

    def self.load(file)
      instance = self.new
      instance.instance_eval(File.read(file), file)

      instance.execute
    end

    def execute
      extend Hawk::Builder
      extend Hawk::S3Uploader
      extend Hawk::Notifier

      notify_users # notify_users will trigger all dependent actions
    end
  end
end
