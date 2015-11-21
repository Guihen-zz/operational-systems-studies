require_relative './command.rb'

module Commands
  class CallToExit < Exception; end

  class Sai < Command
    def execute_with(file_manager)
      raise CallToExit
    end
  end
end
