require_relative './command.rb'

module Commands
  class Mkdir < Command
    def execute
      puts "Creating directory #{args}"
    end
  end
end
