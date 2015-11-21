module Commands
  class AbstractMethodError < RuntimeError; end
  class InvalidArgumentsError < RuntimeError; end
  class InvalidPartitionError < RuntimeError; end

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

      def path
        @path ||= @args.scan(/\/[^\/]+/)
      end

      def directory(path)
        directory = @file_manager.root_directory
        path.each { |dir_name| directory = directory.find(dir_name) }
        directory
      end
  end
end
