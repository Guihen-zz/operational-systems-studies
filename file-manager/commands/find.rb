require_relative './command.rb'

module Commands
  class Find < Command
    def execute
      directory_from, file_name_to_find = get_two_parmeters!

      directory = directory(path(directory_from))
      found_names = recursively_find(directory, file_name_to_find)
      puts found_names.join("\n")
    end

    private

      def recursively_find(directory, filename)
        found_names = []
        directory.all.map do |file_description|
          directory.find(file_description[:name].strip)
        end.each do |file|
          found_names << file.full_name(directory) if file.name.strip == filename
          found_names.concat(recursively_find(file, filename)) if file.directory?
        end
        found_names
      end
  end
end
