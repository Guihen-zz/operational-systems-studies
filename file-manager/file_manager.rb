require_relative './file_manager_components/custom_directory.rb'

class FileManager
  attr_accessor :partition_size, :partition_name, :block_size, :inodes_index
  attr_reader :root_directory

  def initialize(partition_name)
    @partition_name = partition_name
    @partition_size = 32 # 100000000
    @block_size = 4 # 4000
    @inodes_index = 0
  end

  def start_free_space_management
    File.open(partition_name, 'w+b') do |file|
      bitmap_size.times { file.write('1') }
    end
  end

  def start_root_file
    File.open(partition_name, 'r+b') do |file|
      file.seek(root_file_offset)
      @root_directory = CustomDirectory.new(file)
      @root_directory.create('/')
    end
  end

  private

    def bitmap_size
      partition_size / block_size
    end

    def root_file_offset
      bitmap_size
    end
end
