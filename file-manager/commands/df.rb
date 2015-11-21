require_relative './command.rb'
require 'debugger'

module Commands
  class Df < Command
    def execute
      attributes = walk_through_file_system(@file_manager.root_directory)
      attributes[:directory_counter] += 1 # root directory
      attributes[:size_wasted_with_directories] += @file_manager.root_directory.size.to_i % FileManager.block_size
      attributes[:size_wasted_with_directories] += attributes[:directory_counter] * CustomDirectory::ATTRIBUTES_DATA_SIZE
      attributes[:size_wasted_with_files] += attributes[:file_counter] * CustomDirectory::ATTRIBUTES_DATA_SIZE

      puts "Nome da particao: #{@file_manager.partition_name}"
      puts "Utilizando #{attributes[:total_size]}B de #{@file_manager.partition_size}B (#{@file_manager.partition_size - attributes[:total_size]}B livres)"
      puts "Quantidade de diretorios: #{attributes[:directory_counter]}"
      puts "Espaco desperdicado com diretorios: #{attributes[:size_wasted_with_directories]}B"
      puts "Quantidade de arquivos: #{attributes[:file_counter]}"
      puts "Espaco desperdicado com arquivos: #{attributes[:size_wasted_with_files]}B"
    end

    protected
      def walk_through_file_system(directory)
        attributes = {
          directory_counter: 0, # root directory
          file_counter: 0,
          size_wasted_with_files: 0,
          size_wasted_with_directories: 0,
          total_size: 0
        }

        directory.all.map do |file_description|
          directory.find(file_description[:name].strip)
        end.each do |file|
          attributes[:total_size] += file.size.to_i

          if file.directory?
            attributes[:directory_counter] += 1
            attributes[:size_wasted_with_directories] += file.size.to_i % FileManager.block_size

            walk_through_file_system(file).each { |k, v| attributes[k] += v }
          else
            attributes[:file_counter] += 1
            attributes[:size_wasted_with_files] += file.size.to_i % FileManager.block_size
          end
        end

        attributes
      end
  end
end
