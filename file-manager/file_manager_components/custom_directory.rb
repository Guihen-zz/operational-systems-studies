require 'date'
require 'debugger'

class CustomDirectory
  EMPTYDIRSIZE =  8 # next block link
  CONTENTDIRSIZE = 64 # 8 (filesize) + 6 (filename) + {ddmmaaaahhmmss}(14) * 3 + 8 (next_block_link)
  EMPTYLINKSYMBOL = '?'
  EMPTYBYTESYMBOL = '_'

  attr_accessor :partition_name, # the partition name where the filter will be stored
    :parent_directory, # the folder it is inside
    :name, :size, # file name and size
    :created_at, :updated_at, :touched_at, # timestamps
    :block_index, # the current block index
    :next_block_link # the next block it uses if the current block is full

  def initialize(partition_name, parent_directory)
    @partition_name = partition_name
    @parent_directory = parent_directory
    @size = empty_dir_size
    @next_link = empty_link
  end

  def create(name, block_index)
    set_timestamps
    @name = name.rjust(6)
    @block_index = block_index.to_s.rjust(8, '0')

    File.open(partition_name, 'r+b') do |file|
      file.seek(block_index)
      (4000-8).times { file.write(EMPTYBYTESYMBOL) }
      file.write(empty_link)
    end

    @parent_directory.append(self)
  end

  def append(directory)
    File.open(partition_name, 'r+b') do |file|
      file.seek(@block_index.to_i + @size.to_i - 8)
      file.write(directory.size)
      file.write(directory.name) # name with size 14
      file.write(directory.created_at)
      file.write(directory.updated_at)
      file.write(directory.touched_at)
      file.write(directory.block_index)
    end
    @size = (@size.to_i + CONTENTDIRSIZE).to_s
  end

  protected
    def set_timestamps
      date = DateTime.now.strftime("%Y%m%d%H%M%S")
      @created_at = date
      @updated_at = date
      @touched_at = date
    end

    def absolute_path_to_file_as_array
      @name.scan(/(\/[^\/]+)/)
    end

    def empty_dir_size
      EMPTYDIRSIZE.to_s.rjust(8, '0')
    end

    def empty_link
      EMPTYLINKSYMBOL * 8
    end
end
