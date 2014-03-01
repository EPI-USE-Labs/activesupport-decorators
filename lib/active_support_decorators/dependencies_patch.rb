require 'active_support/dependencies'

module ActiveSupport::Dependencies
  alias_method :require_or_load_without_multiple, :require_or_load

  def require_or_load(file_name, const_path = nil)
    order = ActiveSupportDecorators.load_path_order(file_name)

    if ActiveSupportDecorators.debug && order.size > 1
      Rails.try(:logger).try(:debug, "ActiveSupportDecorators: Loading files in order #{order.join(', ')}.")
    end

    order.each do |path|
      require_or_load_without_multiple(path, const_path)
    end
  end
end
