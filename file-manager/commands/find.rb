require_relative './command.rb'

module Commands
  class Find < Command
    def execute
      directory_from, file_to_find = get_two_parmeters!
      puts "Finding in #{directory_from} the file #{file_to_find}"
    end
  end
end
