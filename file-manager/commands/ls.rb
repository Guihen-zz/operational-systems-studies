require_relative './command.rb'

module Commands
  class Ls < Command
    def execute
      directory(path).all.each do |file_attributes|
        last_modified_at = DateTime.parse(file_attributes[:updated_at]).strftime("%e %b %Y %k:%M")
        directory_flag = file_attributes[:magic_number] == CustomDirectory::MAGIC_NUMBER ? 'd' : ' '
        printf("%c %8s %s %s\n", directory_flag, file_attributes[:size].to_i, last_modified_at, file_attributes[:name].strip)
      end
    end
  end
end
