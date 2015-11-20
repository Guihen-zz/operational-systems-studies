require_relative './custom_file.rb'
require 'date'
require 'debugger'

class CustomDirectory < CustomFile
  EMPTYDIRSIZE =  8 # next block link
  CONTENTDIRSIZE = 64 # 8 (filesize) + 6 (filename) + {ddmmaaaahhmmss}(14) * 3 + 8 (next_block_link)

  attr_accessor :parent_directory # the folder it is inside

  def initialize(partition_name, parent_directory)
    @partition_name = partition_name
    @parent_directory = parent_directory
  end

  def create(name, block_index)
    super
    @parent_directory.append(self)
  end

  def find(file_name)
    File.open(partition_name, 'r+b') do |file|
      (4000 / CONTENTDIRSIZE).times do |i|
        file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
        file_attributes = attributes_of(file)
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

  def append(custom_file)
    File.open(partition_name, 'r+b') do |file_handler|
      (4000 / CONTENTDIRSIZE).times do |i|
        file_handler.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
        if file_handler.getc == EMPTYBYTESYMBOL
          file_handler.rewind
          file_handler.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
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
        file_attributes = attributes_of(file)
        if file_attributes[:name] == directory.name
          file.rewind
          file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
          CONTENTDIRSIZE.times { file.write(EMPTYBYTESYMBOL) }
          return @parent_directory.update_file_size_by(@name.strip, - CONTENTDIRSIZE) && reload
        end
      end
    end
  end

  def all
    all_files = []
    File.open(partition_name, 'r+b') do |file|
      (4000 / CONTENTDIRSIZE).times do |i|
        file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
        all_files << attributes_of(file)
      end
    end

    all_files.reject { |file| file[:name] == (EMPTYBYTESYMBOL * FILENAMESIZE) }
  end

  def update_file_size_by(file_name, increased_by)
    File.open(partition_name, 'r+b') do |file|
      (4000 / CONTENTDIRSIZE).times do |i|
        file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
        file_attributes = attributes_of(file)
        if file_attributes[:name].strip == file_name
          former_size = file_attributes[:size]
          file.rewind
          file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
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
      (4000 / CONTENTDIRSIZE).times do |i|
        file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
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
      (4000 / CONTENTDIRSIZE).times do |i|
        file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
        file_attributes = attributes_of(file)
        if file_attributes[:name].strip == file_name
          file.rewind
          file.seek(@block_index.to_i + (i * CONTENTDIRSIZE))
          attributes_format = [ [ :size, 8 ], [ :name, FILENAMESIZE ],
            [ :created_at, 14 ], [ :updated_at, 14 ], [ :touched_at, 14 ] ]

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

  protected

    def content_size
      CONTENTDIRSIZE
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
        size: file.gets(8),
        name: file.gets(6),
        created_at: file.gets(14),
        updated_at: file.gets(14),
        touched_at: file.gets(14),
        block_index: file.gets(8)
      }
    end

    def empty_size
      EMPTYDIRSIZE.to_s.rjust(8, '0')
    end
end
