require_relative './command.rb'

module Commands
  class Mkdir < Command
    def execute
      new_directory = CustomDirectory.new(@file_manager.partition_name, @file_manager.new_block)
      new_directory.create(@args)
      @file_manager.root_directory.append(new_directory)
    end
  end
end
