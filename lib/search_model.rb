class SearchModel
  @search_attrs = []
  class << self; attr_accessor :search_attrs; end
 
  def self.search_attributes(*attributes)
    @search_attrs = attributes.collect(&:to_s)
    attr_accessor *@search_attrs
  end
  
  def initialize(params = nil)
    params = (params || {}).stringify_keys
    self.class.search_attrs.each do |attr|
      send("#{attr}=", params[attr])
    end
  end
  
  def blank?
    scopes.empty?
  end
  
  def results
    search_scope = model_class.scoped({})
    scopes.each do |scope, param|
      search_scope = search_scope.scoped(model_class.send(scope, param).proxy_options)
    end      
    search_scope  
  end
  
  private
    
    def model_class
      self.class.to_s.gsub(/Search$/, '').constantize
    end    
    
    def scopes
      returning [] do |scopes|
        self.class.search_attrs.each do |f|
          value = send(f)
          if set?(value) 
            scopes << ["by_#{f}", value]           
          end
        end
      end
    end

    def set?(value)
      case value.class.to_s
        when 'Array' : value.any? { |v| !v.blank? }
        when /Hash/  : value.values.any? { |v| !v.blank? }
        else           !value.blank?
      end
    end    
      
end
