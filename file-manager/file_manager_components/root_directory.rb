class RootDirectory < CustomDirectory
  class NotAllowedActionError < RuntimeError; end

  SIZE = CONTENTDIRSIZE

  def initialize(partition_name, metadata_index)
    @partition_name = partition_name
    @metadata_index = metadata_index.to_s.rjust(8, '0')
    @size = empty_dir_size
    @name = '/'.rjust(6)
    @parent_directory = self
  end

  def create(block_index)
    set_timestamps
    @block_index = block_index.to_s.rjust(8, '0')

    File.open(partition_name, 'r+b') do |file|
      file.seek(@metadata_index.to_i)
      file.write(@size) # filesize
      file.write(@name) # name with size 6
      file.write(@created_at)
      file.write(@updated_at)
      file.write(@touched_at)
      file.write(@block_index)
      file.seek(@block_index.to_i)
      (4000 - 8).times { file.write(EMPTYBYTESYMBOL) }
      file.write(empty_link)
    end
  end

  def destroy
    raise NotAllowedActionError.new
  end

  def find(file_name)
    return super(file_name) if file_name.strip != '/'

    root_directory = nil
    File.open(partition_name, 'r+b') do |file|
      file.seek(@metadata_index.to_i)
      file_attributes = attributes_of(file)
      root_directory = CustomDirectory.new(@partition_name, self)
      file_attributes.each do |attribute, value|
        root_directory.send("#{attribute}=", value)
      end
    end

    root_directory
  end

  def update_file_size(file_name, new_size)
    return super if file_name.strip != '/'

    File.open(partition_name, 'r+b') do |file|
      file.seek(@metadata_index.to_i)
      file.write(new_size.to_s.rjust(8, '0'))
    end

    true
  end
end
