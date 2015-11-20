require_relative './command.rb'

module Commands
  class Ls < Command
    def execute
      directory(path).all.each do |file_attributes|
        last_modified_at = DateTime.parse(file_attributes[:updated_at]).strftime("%e %b %Y %k:%M")
        printf("%8s %s %s\n", file_attributes[:size].to_i, last_modified_at, file_attributes[:name].strip)
      end
    end
  end
end
