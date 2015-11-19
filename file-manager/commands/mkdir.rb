require_relative './command.rb'

module Commands
  class Mkdir < Command
    def execute
      new_directory = CustomDirectory.new(@file_manager.partition_name, @file_manager.root_directory)
      new_directory.create(@args, @file_manager.new_block)
    end
  end
end
