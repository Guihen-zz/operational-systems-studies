require_relative './command.rb'

module Commands
  class Cp < Command
    def execute
      from, to = get_two_parmeters!
      puts "Copying #{from} to #{to}"
    end
  end
end
