require 'active_support/dependencies'

module ActiveSupport
  module Dependencies
    alias_method :require_or_load_single, :require_or_load

    def require_or_load(file_name, const_path = nil)
      if ActiveSupportDecorators.is_decorator?(file_name)
        # If an attempt is made to load the decorator file (such as eager loading), we
        # need to load the original file and then the decorators.
        original_const_name = ActiveSupportDecorators.original_const_name(file_name)

        if original_const_name
          ActiveSupportDecorators.log "Decorators: Expecting #{file_name} to decorate #{original_const_name}."
          original_const_name.constantize

          ActiveSupportDecorators.all(file_name, const_path).each do |d|
            ActiveSupportDecorators.log "Decorators: Loading #{d} for #{file_name}."
            require_or_load_single(d)
          end

        else
          ActiveSupportDecorators.log "Decorators: Nothing found to load before: #{file_name}."
          require_or_load_single(file_name)
        end

      else
        require_or_load_single(file_name, const_path)

        ActiveSupportDecorators.all(file_name, const_path).each do |d|
          ActiveSupportDecorators.log "Decorators: Loading #{d} for #{file_name}."
          require_or_load_single(d)
        end
      end
    end
  end
end