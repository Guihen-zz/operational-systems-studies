require_relative './file_manager_components/inode.rb'

class FileManager
  NAMESIZE = 14
  INODESAVAILABLE = 500
  attr_accessor :partition_size, :partition_name, :block_size, :inodes_index

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

  def start_inodes_sector
    File.open(partition_name, 'r+b') do |file|
      file.seek(inodes_file_offset)
      INODESAVAILABLE.times { FileManagerComponents::Inode.empty_inode(file) }
    end
  end

  def start_root_file
    File.open(partition_name, 'r+b') do |file|
      file.seek(root_file_offset)
      file.write('/')
    end
  end

  private

    def bitmap_size
      partition_size / block_size
    end

    def inodes_file_offset
      bitmap_size
    end

    def inodes_file_size
      FileManagerComponents::Inode::SIZE * INODESAVAILABLE
    end

    def root_file_offset
      bitmap_size + inodes_file_size
    end
end
