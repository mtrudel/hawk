require 'uri'
require 'cgi'

module Hawk
  module Notifier
    module DSL
      def user(user)
        puts "Warning: UDID check not implemented yet" if user.is_a? Hash
        user = { user => nil } unless (user.is_a? Hash)
        @users ||= {}
        @users.merge!(user)
      end

      def email_subject(subject)
        @email_subject = subject
      end

      def email_body(body)
        @email_body = body
      end
    end

    def itms_url
      "itms-services://?#{URI.encode_www_form(:action => "download-manifest", :url => plist_url)}"
    end

    def escaped_ipa_url
      CGI.escapeHTML(ipa_url)
    end

    def notify_users
      subject = URI.encode(ERB.new(@email_subject).result(binding)).gsub('?','%3F').gsub('&','%26')
      body = URI.encode(ERB.new(@email_body).result(binding)).gsub('?','%3F').gsub('&','%26')
      `open "mailto:?bcc=#{@users.keys.join(',')}&subject=#{subject}&body=#{body}"`
    end
  end
end
