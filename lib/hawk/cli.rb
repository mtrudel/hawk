require 'optparse'

module Hawk
  module CLI
    module Options
      def self.parse!(args)
        options = {}
        optparse = OptionParser.new do |opts|
          opts.banner = "Usage: hawk [options]"

          options[:preserve_ipa] = false
          opts.on( '-p', '--preserve-ipa', 'Leave a copy of the .ipa file in the current directory' ) do
            options[:preserve_ipa] = true
          end

          opts.on( '-h', '--help', 'Display this screen' ) do
            puts opts
            exit
          end
        end
        begin
          optparse.parse!(args)
        rescue 
          puts $!
          puts optparse
          exit
        end

        options
      end
    end

    def self.run(args)
      options = Options.parse!(ARGV)
      hawkfile = closest_hawkfile(Dir.pwd)
      if (hawkfile)
        Dir.chdir(File.dirname(hawkfile))
        Hawk::DSL.load(hawkfile, options)
      else
        puts "Cannot find hawkfile"
      end
    end

    def self.closest_hawkfile(dir)
      file_name = File.join(dir, 'Hawkfile')
      if File.exists?(file_name)
        file_name
      elsif dir == '/'
        nil
      else
        closest_hawkfile(File.expand_path(File.join(dir, '..')))
      end
    end
  end
end

