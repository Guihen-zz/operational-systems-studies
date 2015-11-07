require_relative './command.rb'

module Commands
  class Rm < Command
    def execute
      puts "Removed the file #{args}"
    end
  end
end
