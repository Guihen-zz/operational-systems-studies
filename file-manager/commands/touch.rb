require_relative './command.rb'

module Commands
  class Touch < Command
    def execute
      puts "Touched the file #{args}"
    end
  end
end
