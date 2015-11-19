class RootDirectory < CustomDirectory
  SIZE = 56

  def initialize(partition_name, metadata_index)
    @partition_name = partition_name
    @metadata_index = metadata_index.to_s.rjust(8, '0')
    @size = empty_dir_size
    @name = '/'.rjust(6)
  end

  def create(block_index)
    set_timestamps
    @block_index = block_index.to_s.rjust(8, '0')

    File.open(partition_name, 'r+b') do |file|
      file.seek(@metadata_index.to_i - 1)
      file.write(@size) # filesize
      file.write(@name) # name with size 6
      file.write(@created_at)
      file.write(@updated_at)
      file.write(@touched_at)
      file.seek(@block_index.to_i)
      (4000 - 8).times { file.write(EMPTYBYTESYMBOL) }
      file.write(empty_link)
    end
  end
end
