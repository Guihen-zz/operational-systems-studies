require_relative './command_executor.rb'

class Simulator
  def initialize(input_reader)
    @reader = input_reader
  end

  def start
    print "[ep3]: "
    line = @reader.readline
    CommandExecutor.new(line).execute
  end
end
