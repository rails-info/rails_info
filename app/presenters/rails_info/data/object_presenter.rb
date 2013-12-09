class RailsInfo::Data::ObjectPresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    options.assert_valid_keys(:object)
    
    @object = options[:object]
  end
  
  def row
    content = content_tag :td, class: 'first' do
      check_box_tag "data[]", "#{object[:class].name};#{object['id']}", false, id: "#{object[:class].name.tableize}-#{object['id']}"
    end
    
    object[:class].columns.each do |column|
      value = object[column.name]
      
      if ['string', 'text'].include?(column.type.to_s)
        text = value.present? && value.length > 20 ? "#{value[0,20]}..." : value
        value = content_tag :span, text, title: value
      end
        
      content += content_tag :td, value
    end
    
    content
  end
  
  private
  
  def object
    @object
  end
end