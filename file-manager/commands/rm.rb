require_relative './command.rb'

module Commands
  class Rm < Command
    def execute
      file_name = path.pop
      parent_directory = directory(path)
      file = parent_directory.find(file_name)
      @file_manager.free(file.block_index.to_i)
      file.destroy and parent_directory.unappend(file)
    end
  end
end
