require_relative './command.rb'

module Commands
  class Df < Command
    def execute
      puts "Printing file system informations"
    end
  end
end
