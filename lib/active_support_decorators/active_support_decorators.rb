require 'active_support_decorators/graph'

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
    graph = Graph.new
    graph.add(file_name)

    # If an attempt is made to load the original file, ensure the decorators are loaded afterwards.
    dependencies.each do |path, decorator_paths|
      if file_name.starts_with?(path)
        relative_name = file_name.gsub(path, '')

        decorator_paths.each do |decorator_path|
          decorator_file = "#{decorator_path}#{relative_name}"

          if File.file?(decorator_file) || File.file?(decorator_file + '.rb')
            graph.add_dependency(file_name, decorator_file)
          end
        end
      end

      # If an attempt is made to load a decorator file, ensure the original file is loaded first.
      decorator_paths.each do |decorator_path|
        if file_name.starts_with?(decorator_path)
          relative_name = file_name.gsub(decorator_path, '')
          decorated_file = "#{path}#{relative_name}"

          if File.file?(decorated_file) || File.file?(decorated_file + '.rb')
            graph.add_dependency(decorated_file, file_name)
          end
        end
      end
    end

    graph.resolve_object_order
  end
end