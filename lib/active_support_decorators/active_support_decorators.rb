module ActiveSupportDecorators
  def self.dependencies
    @dependencies ||= {}
  end

  def self.add_dependency(path, decorator_path)
    if dependencies.include?(path)
      dependencies[path] << decorator_path
    else
      dependencies[path] = [decorator_path]
    end
  end

  def self.debug
    @debug ||= false
  end

  def self.debug=(debugging_enabled)
    @debug = debugging_enabled
  end

  def self.load_path_order(file_name)
    file_name_order = [file_name]

    dependencies.each do |path, decorator_paths|
      if file_name.starts_with?(path)
        relative_name = file_name.gsub(path, '')

        decorator_paths.each do |decorator_path|
          decorator_file = "#{decorator_path}#{relative_name}"

          if File.file?(decorator_file) || File.file?(decorator_file + '.rb')
            Rails.logger.debug "ActiveSupportDecorators: Loading '#{decorator_file}' after '#{file_name}'." if debug
            file_name_order << decorator_file
          end
        end
      end
    end

    file_name_order
  end
end