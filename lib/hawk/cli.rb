module Hawk
  module CLI
    def self.run(args)
      hawkfile = closest_hawkfile(Dir.pwd)
      if (hawkfile)
        Dir.chdir(File.dirname(hawkfile))
        Hawk::DSL.load(hawkfile)
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

