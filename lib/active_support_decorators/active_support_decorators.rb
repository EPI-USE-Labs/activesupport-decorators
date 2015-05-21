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

  def self.log(message)
    puts message if debug
  end

  def self.is_decorator?(file_name)
    sanitize(file_name).ends_with?(pattern)
  end

  def self.all(file_name, const_path = nil)
    file = sanitize(file_name)

    if const_path
      file = const_path.underscore
    else
      first_autoload_match = ActiveSupport::Dependencies.autoload_paths.find { |p| file.include?(p) }
      file.sub!(first_autoload_match, '') if first_autoload_match
    end

    relative_target = "#{file}#{pattern}.rb"

    expanded_paths.map { |path| File.join(path, relative_target) }.select { |candidate| File.file?(candidate) }
  end

  def self.original_const_name(file_name)
    first_match = expanded_paths.find { |path| file_name.include?(path) }

    if first_match
      sanitize(file_name).sub("#{first_match}/", '').sub(pattern, '').camelize
    else
      nil
    end
  end

  private
  def self.sanitize(file_name)
    file_name.sub(/\.rb$/, '')
  end
end
