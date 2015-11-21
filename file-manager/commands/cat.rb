require_relative './command.rb'

module Commands
  class Cat < Command
    def execute
      file_name = path.pop
      puts directory(path).find(file_name).read
    end
  end
end
