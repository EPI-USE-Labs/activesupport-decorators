module ActiveSupportDecorators
  def self.auto_decorate_paths=(path_array)
    @auto_decorate_paths = path_array
  end

  def self.auto_decorate_paths
    @auto_decorate_paths ||= []
  end

  def self.auto_decorate_provider_paths=(path_array)
    @auto_decorate_provider_paths = path_array
  end

  def self.auto_decorate_provider_paths
    @auto_decorate_provider_paths ||= []
  end

  def self.load_path_order(file_name)
    file_name_order = [file_name]

    if auto_decorate_paths.any? { |path| file_name.starts_with?(path) }
      relative_name = file_name.gsub(Rails.root.to_s, '')

      auto_decorate_provider_paths.each do |path|
        decorator_file = "#{path}#{relative_name}"
        if File.file?(decorator_file) || File.file?(decorator_file + '.rb')
          file_name_order << decorator_file
        end
      end
    end

    file_name_order
  end
end