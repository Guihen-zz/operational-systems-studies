require_relative './command.rb'

module Commands
  class Mkdir < Command
    def execute
      path = @args.scan(/\/[^\/]+/)
      if path.size == 1
        new_directory = CustomDirectory.new(@file_manager.partition_name, @file_manager.root_directory)
        new_directory.create(path.first, @file_manager.new_block)
      else
        new_directory_name = path.pop
        directory = @file_manager.root_directory
        path.each { |dir_name| directory = directory.find(dir_name) }
        new_directory = CustomDirectory.new(@file_manager.partition_name, directory)
        new_directory.create(new_directory_name, @file_manager.new_block)
      end
    end
  end
end
