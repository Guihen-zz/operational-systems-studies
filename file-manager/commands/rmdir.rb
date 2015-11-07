require_relative './command.rb'

module Commands
  class Rmdir < Command
    def execute
      puts "Removing directory #{args}"
    end
  end
end
