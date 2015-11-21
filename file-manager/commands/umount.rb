require_relative './command.rb'

module Commands
  class Umount < Command
    def execute
      @file_manager.umount!
    end
  end
end
