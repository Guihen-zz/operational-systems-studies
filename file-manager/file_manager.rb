require_relative './file_manager_components/custom_directory.rb'

class FileManager
  attr_accessor :partition_size, :partition_name, :block_size, :inodes_index
  attr_reader :root_directory

  def initialize(partition_name)
    @partition_name = partition_name
    @partition_size = 100000000
    @block_size = 4000
    @inodes_index = 0
  end

  def start_free_space_management
    File.open(partition_name, 'w+b') do |file|
      bitmap_size.times { file.write('1') }
    end
  end

  def start_root_file
    root_block = new_block
    use_block(root_block)
    @root_directory = CustomDirectory.new(partition_name, root_block)
    @root_directory.create('/')
  end

  def new_block
    block_index = -1

    File.open(partition_name, 'r+b') do |file|
      file.seek(bitmap_offset)
      bitmap_size.times do |index|
        zero_to_empty_space = file.getc
        if zero_to_empty_space == '1'
          block_index = root_file_offset + (index * block_size)
          break
        end
      end
    end

    block_index
  end

  def use_block(block_index)
    index = (block_index - root_file_offset) / block_size
    File.open(partition_name, 'r+b') do |file|
      file.seek(index)
      file.write('0')
    end
  end

  private
    def bitmap_offset
      0
    end

    def bitmap_size
      partition_size / block_size
    end

    def root_file_offset
      bitmap_size
    end
end
