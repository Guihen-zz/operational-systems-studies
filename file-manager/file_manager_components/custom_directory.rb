require 'date'

class CustomDirectory
  EMPTYDIRSIZE =  64 # 8 (filesize) + 6 (filename) + {ddmmaaaahhmmss} * 3 + 8 (next_block_link)
  EMPTYLINK = '?'
  EMPTYBYTE = '*'

  attr_accessor :partition_name, :name, :size, :created_at, :updated_at, :touched_at, :block_index

  def initialize(partition_name, block_index)
    @partition_name = partition_name
    @block_index = block_index
  end

  def create(name)
    date = DateTime.now.strftime("%Y%m%d%H%M%S")
    @created_at = date
    @updated_at = date
    @touched_at = date
    @size = empty_dir_size
    @name = name.rjust(6)

    File.open(partition_name, 'r+b') do |file|
      file.seek(@block_index)
      file.write(@size) # filesize
      file.write(@name) # name with size 14
      file.write(@created_at)
      file.write(@updated_at)
      file.write(@touched_at)
      file.write(empty_link)
      (4000 - @size.to_i).times { file.write(EMPTYBYTE) }
    end
  end

  def append(directory)
    File.open(partition_name, 'r+b') do |file|
      file.seek(@block_index + @size.to_i)
      file.write(directory.name)
      file.write(directory.block_index)
    end
    @size = (@size.to_i + 16).to_s
  end

  protected

    def absolute_path_to_file_as_array
      @name.scan(/(\/[^\/]+)/)
    end

    def empty_dir_size
      EMPTYDIRSIZE.to_s.rjust(8, '0')
    end

    def empty_link
      EMPTYLINK * 8
    end
end
