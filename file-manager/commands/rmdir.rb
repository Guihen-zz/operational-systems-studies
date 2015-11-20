require_relative './command.rb'

module Commands
  class Rmdir < Command
    # Cannot remove a directory with children
    def execute
      path = @args.scan(/\/[^\/]+/)
      directory = @file_manager.root_directory
      path.each { |dir_name| directory = directory.find(dir_name) }
      @file_manager.free(directory.block_index.to_i)
      directory.destroy
    end
  end
end
