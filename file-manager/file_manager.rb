class FileManager
  attr_accessor :partition_size, :partition_name, :block_size

  def initialize(partition_name)
    @partition_name = partition_name
    @block_size = 1000
  end

  def start_free_space_management
    bitmap_size = partition_size / block_size
    File.open(partition_name, 'w+b') do |file|
      bitmap_size.times { file.write('0') }
    end
  end
end
