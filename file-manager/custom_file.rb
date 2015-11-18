class CustomFile
  attr_accessor :name, :size, :created_at, :updated_at, :touched_at

  def initialize(name = nil)
    @name = name
  end

  private

    def absolute_path_to_file_as_array
      @name.scan(/(\/[^\/]+)/)
    end
end
