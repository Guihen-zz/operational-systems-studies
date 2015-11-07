require_relative './command.rb'

module Commands
  class Cat < Command
    def execute
      puts "Showing content of file #{args}"
    end
  end
end
