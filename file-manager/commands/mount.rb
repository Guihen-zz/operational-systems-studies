require_relative './command.rb'

module Commands
  class Mount < Command
    def execute
      puts "Mounting #{args}"
    end
  end
end
