require_relative './file_manager_components/root_directory.rb'
require_relative './file_manager_components/fat.rb'

class FileManager
  attr_accessor :partition_size, :partition_name, :block_size
  attr_reader :root_directory, :umounted, :fat
  FREE_SPACE_SYMBOL = '1'
  USED_SPACE_SYMBOL = '0'

  def initialize(partition_name, partition_size = 100000000, block_size = 4000)
    @partition_name = partition_name
    @partition_size = partition_size
    @block_size = block_size

    load!
    start_fat
  end

  def start_fat
    @fat = Fat.new(root_directory, bitmap_size)
    @fat.start
    @fat.log
  end

  def load!
    if !File.exists?(partition_name)
      File.new(partition_name, 'w+b')
      new_free_space_management
      new_root_file
    else
      load_root_file
    end

    @mounted = true
    @@user_data_offset = user_data_offset
    @@bitmap_size = bitmap_size
    @@block_size = @block_size
  end

  def new_block
    block_index = -1

    File.open(partition_name, 'r+b') do |file|
      file.seek(bitmap_offset)
      bitmap_size.times do |index|
        if file.getc == FREE_SPACE_SYMBOL
          block_index = user_data_offset + (index * block_size)
          file.rewind
          file.seek(index)
          file.write(USED_SPACE_SYMBOL)
          break
        end
      end
    end

    block_index
  end

  def free(block_index)
    File.open(partition_name, 'r+b') do |file|
      bitmap_index = (block_index - user_data_offset) / block_size
      file.seek(bitmap_index)
      file.write(FREE_SPACE_SYMBOL)
    end
  end

  def umounted?
    !@mounted
  end

  def umount!
    @mounted = false
  end

  def mount(file_name)
    @partition_name = file_name
    load!
  end

  def self.user_data_offset
    @@user_data_offset
  end

  def self.block_size
    @@block_size
  end

  protected
    def new_free_space_management
      File.open(partition_name, 'r+b') do |file|
        bitmap_size.times { file.write(FREE_SPACE_SYMBOL) }
      end
    end

    def new_root_file
      @root_directory = RootDirectory.new(partition_name, root_block)
      @root_directory.create(new_block)
    end

    def load_root_file
      @root_directory = RootDirectory.load(partition_name, root_block)
    end

    def bitmap_offset
      0
    end

    def bitmap_size
      partition_size / block_size
    end

    def root_block
      bitmap_size
    end

    def user_data_offset
      root_block + RootDirectory::SIZE
    end
end
