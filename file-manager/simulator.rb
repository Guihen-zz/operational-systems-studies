require_relative './command_executor.rb'
require_relative './file_manager.rb'
require_relative './commands/command.rb'

class Simulator
  DEFAULT_PARTITION_NAME = './data/partition'

  def initialize(input_reader)
    @reader = input_reader
  end

  def start
    file_manager = FileManager.new(DEFAULT_PARTITION_NAME)

    loop do
      print "[ep3]: "
      line = @reader.readline
      begin
        CommandExecutor.new(line).execute(file_manager)
      rescue Commands::CallToExit
        break
      rescue CustomFile::FileNotFoundError
        puts "Comando invalido: arquivo ou diretorio nao encontrado."
      rescue Commands::InvalidPartitionError
        puts "Comando invalido: nenhuma particao encontrada."
      end
    end
  end
end
