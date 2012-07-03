module RailsInfo::ResourcesHelper
  TRANSLATED_COLUMNS = []
  
  def resource_tree(presenter, parent_id = '')   
    content = ""
     
    presenter.each do |title, resource_presenter|
      id = parent_id.blank? ? title.parameterize : "#{parent_id}-#{title.parameterize}"
    
      if resource_presenter[:sub_collection]   
        content += content_tag(:li, raw(title) + resource_tree(resource_presenter[:sub_collection], id))  
      else
        content += content_tag(:li, title)
      end      
    end

    content_tag(:ul, raw(content))
  end
  
  def resource_presenter_renderer(presenter)
    params['display_type'] == 'flat' ? raw(flat_resource_presenter_renderer(presenter)) : nested_resource_presenter_renderer(presenter)
  end  
  
  def nested_resource_presenter_renderer(presenter, parent_id = '')
    tabs_for do |tab|
      presenter.each do |title,resource_presenter|  
        id = parent_id.blank? ? title.parameterize : "#{parent_id}-#{title.parameterize}"
        tab_title = resource_presenter[:group_by] ? "#{title} (Group by: #{resource_presenter[:group_by]})" : title    
        tab.create(id, tab_title) do  
          content = ""
          
          resource_presenter[:collection] = [resource_presenter[:collection]] unless resource_presenter[:collection].respond_to?('first')
          
          if resource_presenter[:collection]
            content = render(
              'shared/resource/section', {
                :title => title, :collection => resource_presenter[:collection], :group_by => resource_presenter[:group_by],
                :group_by_values => resource_presenter[:group_by_values]
              }
            )
          end
          
          content += nested_resource_presenter_renderer(resource_presenter[:sub_collection], id) if resource_presenter[:sub_collection]
                    
          raw content
        end
      end
    end
  end
  
  def flat_resource_presenter_renderer(presenter, level = '')
    content = ""
    
    presenter.each do |title,resource_presenter|          
      content += render('shared/resource/section', :title => "#{level} #{title}", :collection => resource_presenter[:collection]) if resource_presenter[:collection]
      
      content += flat_resource_presenter_renderer(resource_presenter[:sub_collection], "#{level} -") if resource_presenter[:sub_collection]
    end   
    
    content
  end
  
  def collection_map(collection_map)
    collection = []
    
    collection_map.each do |sub_collection|
      sub_collection.each do |resource|
        collection << resource
      end
    end
    
    collection_map.clear
    
    collection
  end
  
  def grouped_collection(title, collection, group_by)
    @grouped_collections ||= {}
    
    collection_key = "#{title}-{group_by}-#{collection.length}"
    
    return @grouped_collections[collection_key] if @grouped_collections[collection_key]
    
    @grouped_collections[collection_key] = ActiveSupport::OrderedHash.new

    collection.each do |element|  
      if element.is_a?(Hash)
        key = element[group_by.to_s]
      elsif element.respond_to?('translation') && element.translation.respond_to?(group_by)
        key = element.translation.send(group_by)
      else
        key = element.send(group_by)
      end
      
      if @grouped_collections[collection_key].has_key?(key)
        @grouped_collections[collection_key][key] << element
      else
        @grouped_collections[collection_key][key] = [element]
      end
    end
    
    @grouped_collections[collection_key]
  end
  
  def group_columns(title, collection, group_by = nil, group_by_values = nil)
    collection_columns = grouped_collection(title, collection, group_by).keys
    
    if group_by_values.is_a?(Array)
      group_by_values.delete_if {|c| !collection_columns.include?(c) }
      collection_columns.delete_if {|c| group_by_values.include?(c) }
      group_by_values + collection_columns
    else
      collection_columns
    end
  end
  
  def resource_columns(collection, group_by = nil)
    collection_columns = []
    
    if collection.first.is_a?(Array)
      raise "Please wrap the :collection by help.collection_map: #{collection.inspect}"
    elsif collection.first.is_a?(Hash)
      collection_columns = collection.first[:class].columns.map(&:name)
    else
      collection_columns = collection.first.attributes.keys
    end
      
    exclude_columns = [
      'current_code', 'last_code' # WorkflowControllerType binary columns
    ]
    
    exclude_columns << group_by if group_by
    
    collection_columns.delete_if {|c| exclude_columns.include?(c) }
  
    unless collection.first.is_a?(Hash)
      TRANSLATED_COLUMNS.each do |translated_column|
        if !collection.first.attributes[translated_column] && collection.first.respond_to?('translation') && collection.first.translation.respond_to?(translated_column)
          collection_columns << translated_column
        end
      end
      end
       
    first_columns = ['id', 'sort_order', 'order', 'position', 'type', 'state', 'name', 'label', 'title', 'slug']    
    first_columns.delete_if {|c| !collection_columns.include?(c) }
    collection_columns.delete_if {|c| first_columns.include?(c) }
    
    bool_columns = ['final' ,'public', 'hidden']
    bool_columns.delete_if {|c| !collection_columns.include?(c) }
    collection_columns.delete_if {|c| bool_columns.include?(c) } 
    
    able_columns = collection_columns.select {|v| v.match('able') }  
    collection_columns.delete_if {|c| able_columns.include?(c) }    
    
    is_columns = collection_columns.select {|v| v.match('is_') }  
    collection_columns.delete_if {|c| is_columns.include?(c) }    
    
    id_columns = collection_columns.select {|v| v.match('_id') || v.match('_type') }  
    collection_columns.delete_if {|c| id_columns.include?(c) }    
    
    at_columns = collection_columns.select {|v| v.match('_at') }     
    collection_columns.delete_if {|c| at_columns.include?(c) }
    
    last_columns = []    
    last_columns.delete_if {|c| !collection_columns.include?(c) }    
    collection_columns.delete_if {|c| last_columns.include?(c) }
    
    standard_rails_timestamps = ['created_at', 'updated_at']
    standard_rails_timestamps.delete_if {|c| !at_columns.include?(c) }
    at_columns.delete_if {|c| at_columns.include?(c) }
    
    content_for :columns_order, "first_columns + collection_columns + bool_columns + able_columns + is_columns + id_columns + at_columns + last_columns + standard_rails_timestamps" unless content_for?(:columns_order)
    
    first_columns + collection_columns + bool_columns + able_columns + is_columns + id_columns + at_columns + last_columns + standard_rails_timestamps
  end
  
  def resource_cell(row, column)
    if row.is_a?(Hash)
      return "" unless row.has_key?(column)
      
      content = row[column].to_s
    else
      return "" unless row.respond_to?(column)
      
      content = row.send(column).to_s
    end
    
    truncate_length = params['truncate_length'] ? params['truncate_length'].to_i : 50
    
    content = content_tag(:span, truncate(raw(content), :length => truncate_length), :title => content) if content.length > truncate_length
      
    content
  end 
end