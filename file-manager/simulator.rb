require_relative './command_executor.rb'

class Simulator
  def initialize(input_reader)
    @reader = input_reader
  end

  def start
    loop do
      print "[ep3]: "
      line = @reader.readline
      begin
        CommandExecutor.new(line).execute
      rescue Commands::CallToExit
        puts 'Exiting...'
        break
      rescue Commands::InvalidArgumentsError
        puts 'Invalid agurments'
      end
    end
  end
end
