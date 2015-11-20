require_relative './command_executor.rb'
require_relative './file_manager.rb'
require_relative './commands/command.rb'

class Simulator
  def initialize(input_reader)
    @reader = input_reader
  end

  def start
    file_manager = FileManager.new('./data/partition')
    file_manager.start_free_space_management
    file_manager.start_root_file

    loop do
      print "[ep3]: "
      line = @reader.readline
      begin
        CommandExecutor.new(line).execute(file_manager)
      rescue Commands::CallToExit
        break
      rescue CustomDirectory::FileNotFoundError
        puts "Comando invalido: arquivo ou diretorio nao encontrado."
      end
    end
  end
end
