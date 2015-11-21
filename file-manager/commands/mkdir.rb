require_relative './command.rb'

module Commands
  class Mkdir < Command
    def execute
      file_name = path.pop
      validate_file_name_length!(file_name)
      directory = directory(path)

      new_directory = CustomDirectory.new(@file_manager.partition_name, directory)
      new_directory.create(file_name, @file_manager.new_block)
    end
  end
end
