require_relative './command.rb'

module Commands
  class Ls < Command
    def execute
      path = @args.scan(/\/[^\/]+/)
      directory = @file_manager.root_directory
      path.each { |dir_name| directory = directory.find(dir_name) }

      directory.all.each do |file_attributes|
        last_modified_at = DateTime.parse(file_attributes[:updated_at]).strftime("%e %b %Y %k:%M:%S")
        printf("%8s %s14 %6s\n", file_attributes[:size].to_i, last_modified_at, file_attributes[:name])
      end
    end
  end
end
