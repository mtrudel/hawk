require 'uri'
require 'cgi'

module Hawk
  module Notifier
    module DSL
      def user(user)
        @users ||= []
        @users << user
      end

      def email_subject(subject)
        @email_subject = subject
      end

      def email_body(body)
        @email_body = body
      end
    end

    def notify_users
      subject = URI.encode(ERB.new(@email_subject).result(binding)).gsub('?','%3F').gsub('&','%26')
      body = URI.encode(ERB.new(@email_body).result(binding)).gsub('?','%3F').gsub('&','%26')
      `open "mailto:?bcc=#{@users.join(',')}&subject=#{subject}&body=#{body}"`
    end
  end
end
