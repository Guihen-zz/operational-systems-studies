require_relative './command.rb'

module Commands
  class Umont < Command
    def execute
      puts "Umounting the file system"
    end
  end
end
