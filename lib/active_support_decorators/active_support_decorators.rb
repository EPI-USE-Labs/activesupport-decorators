module ActiveSupportDecorators
  DECORATOR_PATTERN = '_decorator'

  def self.clear
    dependencies.clear
  end

  def self.dependencies
    @dependencies ||= {}
  end

  def self.add(path, decorator_path)
    dependencies[path] ||= []
    dependencies[path] << decorator_path
  end

  def self.debug
    @debug ||= false
  end

  def self.debug=(debugging_enabled)
    @debug = debugging_enabled
  end

  private
  def self.load_path_order(file_name)
    # Do not process with .rb extension if provided.
    sanitized_file_name = file_name.sub(/\.rb$/, '')
    decorated_file = nil
    decorators = []

    dependencies.each do |path, decorator_paths|
      decorator_paths.each do |decorator_path|
        # If an attempt is made to load the original file, ensure the decorators are loaded afterwards.
        if sanitized_file_name.starts_with?(path)
          relative_name = sanitized_file_name.sub(path, '')
          candidate_file = "#{decorator_path}#{relative_name}#{DECORATOR_PATTERN}"

          if File.file?(candidate_file + '.rb')
            decorated_file = sanitized_file_name
            decorators << candidate_file
          end
        end

        # If an attempt is made to load a decorator file, ensure the original/decorated file is loaded first.
        # This is only supported when a decorator was not added with add_global.
        if sanitized_file_name.starts_with?(decorator_path)
          relative_name = sanitized_file_name.sub(decorator_path, '')
          candidate_file = "#{path}#{relative_name}".sub(/#{DECORATOR_PATTERN}$/, '')

          if File.file?(candidate_file + '.rb')
            fail "File #{sanitized_file_name} is a decorator for #{candidate_file}, but this file is already
                  decorating #{decorated_file}." unless decorated_file.nil? || decorated_file == candidate_file
            decorated_file = candidate_file
            decorators << sanitized_file_name
          end
        end
      end
    end

    if decorated_file
      # Decorators are sorted to ensure the load order is always the same.
      [decorated_file] + decorators.sort
    else
      [sanitized_file_name]
    end
  end
end
