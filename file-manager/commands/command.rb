module Commands
  class AbstractMethodError < RuntimeError; end
  class InvalidArgumentsError < RuntimeError; end
  class InvalidPartitionError < RuntimeError; end
  class FileNameError < RuntimeError; end
  class InvalidCommandError < RuntimeError; end

  class Command

    attr_reader :args

    def initialize(args)
      @args = args
    end

    def execute_with(file_manager)
      raise InvalidPartitionError.new if file_manager.umounted?

      @file_manager = file_manager
      execute
    end

    protected
      def execute
        raise AbstractMethodError.new
      end

      def get_two_parmeters!
        parameters = args.scan(/\S+/)
        if parameters.size == 2
          parameters.slice(0, 2)
        else
          raise InvalidArgumentsError.new
        end
      end

      def path(other = false)
        path = other || @args
        @path ||= path.scan(/\/[^\/]+/)
      end

      def directory(path)
        directory = @file_manager.root_directory
        path.each { |dir_name| directory = directory.find(dir_name[1..-1]) }
        directory
      end

      def validate_file_name_length!(file_name)
        raise FileNameError.new if file_name.size > CustomFile::FILENAME_SIZE
      end
  end
end
