require_relative './command.rb'

module Commands
  class PartitionAlreadyMountedError < RuntimeError; end

  class Mount < Command
    def execute_with(file_manager)
      @file_manager = file_manager
      execute
    end

    def execute
      if @file_manager.umounted?
        @file_manager.mount(@args)
      else
        raise PartitionAlreadyMountedError.new
      end
    end
  end
end
