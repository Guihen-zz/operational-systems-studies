require 'date'
require 'debugger'

class CustomDirectory
  class FileNotFoundError < RuntimeError; end

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
  end

  def create(name, block_index)
    set_timestamps
    @size = empty_dir_size
    @next_link = empty_link
    @name = name.rjust(6)
    @block_index = block_index.to_s.rjust(8, '0')
    File.open(partition_name, 'r+b') do |file|
      file.seek(block_index)
      (4000 - 8).times { file.write(EMPTYBYTESYMBOL) }
      file.write(empty_link)
    end

    @parent_directory.append(self)
  end

  def find(file_name)
    File.open(partition_name, 'r+b') do |file|
      (4000 / CONTENTDIRSIZE).times do |i|
        file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
        file_attributes = attributes(file)
        if file_attributes[:name].strip == file_name
          founded_directory = CustomDirectory.new(@partition_name, self)
          file_attributes.each do |attribute, value|
            founded_directory.send("#{attribute}=", value)
          end
          return founded_directory
        end

        file.rewind
      end
    end

    raise FileNotFoundError.new
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

  def destroy
    File.open(partition_name, 'r+b') do |file|
      file.seek(@block_index.to_i)
      4000.times { file.write(EMPTYBYTESYMBOL) }
    end
    @parent_directory.unappend(self)

    self.freeze
  end

  def unappend(directory)
    File.open(partition_name, 'r+b') do |file|
      (4000 / CONTENTDIRSIZE).times do |i|
        file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
        file_attributes = attributes(file)
        if file_attributes[:name] == directory.name
          file.rewind
          file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
          CONTENTDIRSIZE.times { file.write(EMPTYBYTESYMBOL) }
          break
        end
      end
    end
  end

  protected
    def attributes(file)
      {
        size: file.gets(8),
        name: file.gets(6),
        created_at: file.gets(14),
        updated_at: file.gets(14),
        touched_at: file.gets(14),
        block_index: file.gets(8)
      }
    end

    def set_timestamps
      date = DateTime.now.strftime("%Y%m%d%H%M%S")
      @created_at = date
      @updated_at = date
      @touched_at = date
    end

    def empty_dir_size
      EMPTYDIRSIZE.to_s.rjust(8, '0')
    end

    def empty_link
      EMPTYLINKSYMBOL * 8
    end
end
