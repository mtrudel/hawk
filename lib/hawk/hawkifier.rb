require 'erb'

module Hawk
  class Hawkifier
    def initialize(dir)
      @dir = dir
    end

    def hawkify
      files.each do |name, contents|
        write_file_if_not_exist(name, contents)
      end
      puts "hawkify done"
    end

    private
    def files
      { 'Hawkfile' => ERB.new(File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'Hawkfile.erb'))).result }
    end

    def write_file_if_not_exist(name, contents)
      file = File.join(@dir, name)
      if (File.exists?(file))
        puts "hawkify skipping #{name}; file exists"
      else
        File.open(file, 'w') do |f|
          puts "hawkify writing #{name}"
          f.write(contents)
        end
      end
    end
  end
end
