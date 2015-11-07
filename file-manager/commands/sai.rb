require_relative './command.rb'

module Commands
  class CallToExit < Exception; end

  class Sai < Command
    def execute
      raise CallToExit
    end
  end
end
