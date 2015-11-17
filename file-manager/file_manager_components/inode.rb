require_relative '../file_manager.rb'
require 'date'

module FileManagerComponents
  class Inode
    SIZE = 128 # 8 (filesize) + 14 (filename) + {ddmmaaaahhmmss} * 3 + 8 * (size of ruby's Integer: 8)
    EMPTYCELL = -1

    def self.empty_inode(file)
      FileManager::NAMESIZE.times { file.write('I') }
      file.write('00000000')
      3.times { file.write(DateTime.now.strftime("%Y%m%d%H%M%S")) }
      8.times { file.write('00000000') }
    end
  end
end
