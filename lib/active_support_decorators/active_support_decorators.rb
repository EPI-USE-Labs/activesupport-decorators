require 'active_support_decorators/graph'

module ActiveSupportDecorators
  Dependency = Struct.new(:path, :decorator_path, :file_pattern)

  def self.clear
    dependencies.clear
  end

  def self.dependencies
    @dependencies ||= []
  end

  def self.add(path, decorator_path, file_pattern = '_decorator')
    dependencies << Dependency.new(path, decorator_path, file_pattern)
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
    sanitized_file_name = file_name.sub(/\.rb$/,'')

    graph = Graph.new
    graph.add(sanitized_file_name)

    dependencies.each do |dep|
      # If an attempt is made to load the original file, ensure the decorators are loaded afterwards.
      if sanitized_file_name.starts_with?(dep.path)
        relative_name = sanitized_file_name.sub(dep.path, '')
        decorator_file = "#{dep.decorator_path}#{relative_name}#{dep.file_pattern}"

        if File.file?(decorator_file + '.rb')
          graph.add_with_edge(sanitized_file_name, decorator_file)
        end
      end

      # If an attempt is made to load a decorator file, ensure the original/decorated file is loaded first.
      # This is only supported when a decorator was not added with add_global.
      if dep.path && sanitized_file_name.starts_with?(dep.decorator_path)
        relative_name = sanitized_file_name.sub(dep.decorator_path, '')
        decorated_file = "#{dep.path}#{relative_name}".sub(/#{dep.file_pattern}$/, '')

        if File.file?(decorated_file + '.rb')
          graph.add_with_edge(decorated_file, sanitized_file_name)
        end
      end
    end

    graph.list_by_order
  end
end
