require_relative './command.rb'

module Commands
  class Ls < Command
    def execute
      puts "listing the directory #{args}"
    end
  end
end
