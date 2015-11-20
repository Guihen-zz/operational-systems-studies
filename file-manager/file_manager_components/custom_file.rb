require 'date'

class CustomFile
  EMPTYLINKSYMBOL = '?'
  EMPTYBYTESYMBOL = '_'
  FILENAMESIZE = 6
  HEADERSIZE = 8 # next_link(8)

  attr_accessor :partition_name, # the partition name where the filter will be stored
    :name, :size, # file name and size
    :created_at, :updated_at, :touched_at, # timestamps
    :block_index, # the current block index
    :next_block_link # the next block it uses if the current block is full

  def initialize(partition_name)
    @partition_name = partition_name
  end

  def create(name, block_index)
    set_timestamps
    @size = empty_size
    @next_link = empty_link
    @name = name.rjust(6)
    @block_index = block_index.to_s.rjust(8, '0')
    File.open(partition_name, 'r+b') do |file|
      file.seek(block_index)
      (4000 - 8).times { file.write(EMPTYBYTESYMBOL) }
      file.write(empty_link)
    end
  end

  protected

    def empty_link
      EMPTYLINKSYMBOL * 8
    end

    def empty_size
      HEADERSIZE.to_s.rjust(8, '0')
    end

    def content_size
      empty_size.to_i + @size.to_i
    end

    def set_timestamps
      date = DateTime.now.strftime("%Y%m%d%H%M%S")
      @created_at = date
      @updated_at = date
      @touched_at = date
    end
end
