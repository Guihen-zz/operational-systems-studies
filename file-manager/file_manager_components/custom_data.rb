class CustomData
  MAGIC_NUMBER = 'X'

  attr_reader :block_index, :partition_name
  
  def initialize(partition_name, block_index)
    @partition_name = partition_name
    @block_index = block_index
    @magic_number = MAGIC_NUMBER
  end

  def next_block_link
    next_block_link = 0
    File.open(@partition_name, 'r+b') do |file|
      file.seek(@block_index.to_i + 4000 - 8)
      next_block_link = file.gets(8)
    end
    next_block_link
  end
end
