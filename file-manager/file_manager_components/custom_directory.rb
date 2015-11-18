require 'date'

class CustomDirectory
  EMPTYDIRSIZE =  64 # 8 (filesize) + 6 (filename) + {ddmmaaaahhmmss} * 3 + 8 (next_block_link)
  EMPTYLINK = '?'

  attr_accessor :partition, :name, :size, :created_at, :updated_at, :touched_at, :custom_files

  def initialize(partition)
    @partition = partition
  end

  def create(name)
    @partition.write(empty_dir_size) # filesize
    @partition.write(name.rjust(6)) # name with size 14
    3.times { @partition.write(DateTime.now.strftime("%Y%m%d%H%M%S")) } # created / updated / last_modified
    @partition.write(empty_link)
  end

  private

    def absolute_path_to_file_as_array
      @name.scan(/(\/[^\/]+)/)
    end

    def empty_dir_size
      EMPTYDIRSIZE.to_s.rjust(8, '0')
    end

    def empty_link
      EMPTYLINK * 8
    end
end
