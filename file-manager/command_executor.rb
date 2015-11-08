Dir["./commands/*.rb"].each { |file| require_relative file }

class CommandExecutor
  def initialize(input)
    @input = input
  end

  def execute
    command = @input.match(/(?<command>\w+)\s*(?<args>.*)/)
    if command
      execute_command(command[:command], command[:args])
    end
  end

  private
    def execute_command(command, args= nil)
      class_name = command[0, 1].upcase + command[1 .. -1]
      Commands.const_get(class_name).new(args).execute
    end
end
