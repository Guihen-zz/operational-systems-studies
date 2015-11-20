require_relative './command.rb'

module Commands
  class Touch < Command
    def execute
      file_name = path.pop
      directory = directory(path)

      begin
        directory.touch!(file_name)
      rescue CustomFile::FileNotFoundError
        new_file = CustomFile.new(@file_manager.partition_name)
        new_file.create(file_name, @file_manager.new_block)
        directory.append(new_file)
      end
    end
  end
end
