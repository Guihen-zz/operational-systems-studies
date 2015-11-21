require_relative './custom_data.rb'

class Fat
  EMPTY = 0
  FINAL = -1

  def initialize(root_directory, size)
    @root_directory = root_directory
    @size = size
    @offset = FileManager.user_data_offset
    @block_size = FileManager.block_size
  end

  def start
    @table = Array.new(@size, EMPTY)
    @table[0] = FINAL # Root directory
    map(@root_directory)
  end

  def log
    File.open('data/fat', 'wb') do |file|
      file.write(@table.join("\n"))
    end
  end

  def get(index)
    @table[index]
  end

  def free(index)
    @table[index] = EMPTY
  end

  def map_file(file)
    current_file = file
    loop do
      current_file = CustomData.new(current_file.partition_name, current_file.next_block_link)
      next_block_link = index(current_file.next_block_link.to_i, true)
      @table[index(current_file.block_index.to_i)] = next_block_link

      break if next_block_link == FINAL
    end
  end

  def use!(index)
    @table[index] = FINAL
  end

  protected

    def map(directory)
      directory.all.map do |file_description|
        directory.find(file_description[:name].strip)
      end.each do |file|
        @table[index(file.block_index.to_i)] = index(file.next_block_link.to_i, true)

        if file.directory?
          map(file)
        elsif index(file.next_block_link.to_i) != 0
          map_file(file)
        end
      end
    end

    def index(user_data_block_index, next_link = false)
      return FINAL if next_link && user_data_block_index == 0
      return 0 if user_data_block_index == 0
      (user_data_block_index - @offset) / @block_size
    end
end
