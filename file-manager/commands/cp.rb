require_relative './command.rb'

module Commands
  class FileAlreadyExistsError < RuntimeError; end
  class InvalidSourceFileError < RuntimeError; end

  class Cp < Command
    def execute
      from, to = get_two_parmeters!

      file_name = path(to).pop
      directory = directory(path)

      begin
        directory.find(file_name)
        raise FileAlreadyExistsError.new
      rescue CustomFile::FileNotFoundError
        begin
          File.open(from, 'r') do |file|
            new_file = CustomFile.new(@file_manager.partition_name)
            new_file.create(file_name, @file_manager.new_block)
            new_file.write(file.gets(nil), @file_manager)
            directory.append(new_file)
          end
        rescue Errno::ENOENT
          raise Commands::InvalidSourceFileError.new
        end
      end
    end
  end
end
