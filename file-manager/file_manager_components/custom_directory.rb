require_relative './custom_file.rb'
require 'date'

class CustomDirectory < CustomFile
  ATTRIBUTES_DATA_SIZE = 70 # magic_number (1) + file_size (8) + file_name (11) + timestamps{ddmmaaaahhmmss} (14) * 3 + next_block_link (8)
  MAGIC_NUMBER = '1'

  attr_accessor :parent_directory # the folder it is inside

  def initialize(partition_name, parent_directory)
    @partition_name = partition_name
    @parent_directory = parent_directory
    @magic_number = MAGIC_NUMBER
  end

  def create(name, block_index)
    super
    @parent_directory.append(self)
  end

  def find(file_name)
    File.open(partition_name, 'r+b') do |file|
      (4000 / ATTRIBUTES_DATA_SIZE).times do |i|
        file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
        file_attributes = attributes_of(file)
        if file_attributes[:name].strip == file_name
          if file_attributes[:magic_number] == MAGIC_NUMBER
            founded_directory = CustomDirectory.new(@partition_name, self)
          else
            founded_directory = CustomFile.new(@partition_name)
          end

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

  def append(custom_file)
    File.open(partition_name, 'r+b') do |file_handler|
      (4000 / ATTRIBUTES_DATA_SIZE).times do |i|
        file_handler.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
        if file_handler.getc == EMPTY_BYTES_SYMBOL
          file_handler.rewind
          file_handler.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
          file_handler.write(custom_file.magic_number)
          file_handler.write(custom_file.size)
          file_handler.write(custom_file.name)
          file_handler.write(custom_file.created_at)
          file_handler.write(custom_file.updated_at)
          file_handler.write(custom_file.touched_at)
          file_handler.write(custom_file.block_index)
          return @parent_directory.update_file_size_by(@name.strip, custom_file.content_size) && reload
        end
        file_handler.rewind
      end
    end

    false
  end

  def destroy
    super
    @parent_directory.unappend(self)
  end

  def unappend(custom_file)
    File.open(partition_name, 'r+b') do |file|
      (4000 / ATTRIBUTES_DATA_SIZE).times do |i|
        file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
        file_attributes = attributes_of(file)
        if file_attributes[:name] == custom_file.name
          file.rewind
          file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
          ATTRIBUTES_DATA_SIZE.times { file.write(EMPTY_BYTES_SYMBOL) }
          return @parent_directory.update_file_size_by(@name.strip, - custom_file.content_size) && reload
        end
      end
    end
  end

  def all
    all_files = []
    File.open(partition_name, 'r+b') do |file|
      (4000 / ATTRIBUTES_DATA_SIZE).times do |i|
        file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
        all_files << attributes_of(file)
      end
    end

    all_files.reject { |file| file[:name] == (EMPTY_BYTES_SYMBOL * FILENAME_SIZE) }
  end

  def update_file_size_by(file_name, increased_by)
    File.open(partition_name, 'r+b') do |file|
      (4000 / ATTRIBUTES_DATA_SIZE).times do |i|
        file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
        file_attributes = attributes_of(file)
        if file_attributes[:name].strip == file_name
          former_size = file_attributes[:size]
          file.rewind
          file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE) + 1)
          file.write((former_size.to_i + increased_by).to_s.rjust(8, '0'))
          return @parent_directory.update_file_size_by(@name.strip, increased_by) && reload
        end

        file.rewind
      end
    end

    false
  end

  def touch!(file_name)
    File.open(partition_name, 'r+b') do |file|
      (4000 / ATTRIBUTES_DATA_SIZE).times do |i|
        file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
        file_attributes = attributes_of(file)
        if file_attributes[:name].strip == file_name
          founded_directory = CustomDirectory.new(@partition_name, self)
          file_attributes.each do |attribute, value|
            founded_directory.send("#{attribute}=", value)
          end

          return update_attributes(file_name, { touched_at: date_time_now })
        end

        file.rewind
      end
    end

    raise FileNotFoundError.new
  end

  def update_attributes(file_name, updated_attributes)
    File.open(partition_name, 'r+b') do |file|
      (4000 / ATTRIBUTES_DATA_SIZE).times do |i|
        file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
        file_attributes = attributes_of(file)
        if file_attributes[:name].strip == file_name
          file.rewind
          file.seek(@block_index.to_i + (i * ATTRIBUTES_DATA_SIZE))
          attributes_format = [ [ :magic_number, 1 ], [ :size, 8 ],
            [ :name, FILENAME_SIZE ], [ :created_at, 14 ], [ :updated_at, 14 ],
            [ :touched_at, 14 ] ]

          attributes_format.each do |attribute_format|
            if updated_attributes.has_key?(attribute_format.first)
              file.write(updated_attributes[attribute_format.first].to_s.rjust(attribute_format.last, '0'))
            else
              file.seek(attribute_format.last, IO::SEEK_CUR)
            end
          end

          return true
        end

        file.rewind
      end
    end

    false
  end

  def write(string)
    raise NameError.new
  end

  def directory?
    true
  end

  protected

    def content_size
      ATTRIBUTES_DATA_SIZE
    end

    def reload
      self_object = @parent_directory.find(name.strip)

      @size = self_object.size
      @created_at = self_object.created_at
      @updated_at = self_object.updated_at
      @touched_at = self_object.touched_at

      true
    end

    def attributes_of(file)
      {
        magic_number: file.getc,
        size: file.gets(8),
        name: file.gets(FILENAME_SIZE),
        created_at: file.gets(14),
        updated_at: file.gets(14),
        touched_at: file.gets(14),
        block_index: file.gets(8)
      }
    end

    def empty_size
      FILE_HEADER_SIZE.to_s.rjust(8, '0')
    end
end
