class RailsInfo::Data::RowSetPresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    options.assert_valid_keys(:row_set)
    
    @row_set = options[:row_set]
  end
  
  def name
    row_set.first[:class].name.tableize.humanize
  end
 
  def head
    title, group_by = nil, ''
    content = content_tag :th, '', class: 'first'
    column_index = 0

    resource_columns(row_set, group_by).each do |column|
      style = column == group_by ? 'color:red;' : ''
      sub_content = column == group_by || title == nil ? column : link_to(column, uri_with_new_param('group_by_title[' + title + ']', column))
      content += content_tag :th, sub_content, style: style#, class: klass
      column_index += 1
    end
    
    content
  end
  
  def objects
    @objects ||= row_set.map{|object| ::RailsInfo::Data::ObjectPresenter.new(subject, object: object) }
  end
  
  private
  
  def row_set
    @row_set
  end
end