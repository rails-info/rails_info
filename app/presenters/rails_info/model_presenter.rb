class RailsInfo::ModelPresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    @rails_info_model = ::RailsInfo::Model.new
    @list = @rails_info_model.list
  end
  
  def count
    @list.keys.length.inspect
  end
  
  def list
    if @list.none?
      I18n.t('rails_info.data.index.no_models_found')
    else
      @list.map{|row_set| ::RailsInfo::Data::RowSetPresenter.new(subject, row_set: row_set) }.each do |row_set_presenter|
        yield row_set_presenter
      end
      
      ""
    end
  end
  
  def hash_tree(hash = nil, options = { parent: '' })
    options.assert_valid_keys(:parent)
    
    hash ||= @list
    parent = options[parent].to_s
    
    content = ''
    
    hash.keys.sort.each do |key|
      value = hash[key]
      
      if value.is_a?(Hash) && !value.empty?  
        sub_content = hash_tree(value, parent: parent.blank? ? key : parent + "::" + key)
        sub_content = (key + @rails_info_model.associations(key, parent: parent) + " " + sub_content).html_safe
        content += content_tag(:li, sub_content)  
      else        
        content += content_tag(:li, key + @rails_info_model.associations(key, parent: parent))
      end
    end
    
    content_tag(:ul, content.html_safe)
  end
  
  def creately
    content_tag :pre, @list.keys.sort.map{|key| creately_for_model(key, @list[key]) }.join('')
  end
  
  private
  
  def creately_for_model(key, model)
    columns = @rails_info_model.columns_for(key, parent: nil)
    content = "#{key}\n--\n"
    
    if columns.any?
      columns.each do |column|
        content += "#{column},INT,FK\n"
      end
    end
    
    content += "--\nPRIMARY,id\n"
    
    content
  end
end