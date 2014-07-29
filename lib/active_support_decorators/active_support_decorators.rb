module ActiveSupportDecorators
  def self.paths
    @paths ||= []
  end

  def self.pattern
    @pattern ||= '_decorator'
  end

  def self.pattern=(pattern)
    @pattern = pattern
  end

  def self.expanded_paths
    paths.map { |p| Dir[p] }.flatten
  end

  def self.debug
    @debug ||= false
  end

  def self.debug=(debugging_enabled)
    @debug = debugging_enabled
  end

  private
  def self.all_autoload_paths
    return [] unless defined?(Rails)
    all_modules = [::Rails.application] + ::Rails::Engine.subclasses.map(&:instance)
    all_modules.map { |mod| mod.send(:_all_autoload_paths) }.flatten
  end

  def self.relative_search_path(file_name, const_path = nil)
    file = file_name

    if const_path
      file = const_path.underscore
    else
      sanitized_file_name = file_name.sub(/\.rb$/, '')
      first_load_path_match = all_autoload_paths.find { |p| file_name.include?(p) }
      file = sanitized_file_name.sub(first_load_path_match, '') if first_load_path_match
    end
    "#{file}#{pattern}.rb"
  end

  def self.load_path_order(file_name, const_path = nil)
    order = [file_name]

    expanded_paths.each do |path|
      candidate_file = File.join(path, relative_search_path(file_name, const_path))
      order << candidate_file if File.file?(candidate_file)
    end

    order
  end
end
