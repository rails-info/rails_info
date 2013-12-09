class RailsInfo::Model
  # TODO: Live reload of ruby code as maybe seen here with require_or_load path https://github.com/Tho85/sunspot/blob/f9f6f9666e6df1a0e92c0d8070f7007075f75071/sunspot_rails/lib/sunspot/rails/tasks.rb 
  def classes
    return @classes if @classes
    
    #model_names = Dir.chdir(File.join(Rails.root, 'app', 'models')) { Dir["*.rb"] }
    #model_names = Dir.chdir(File.expand_path('../../../../../../../reqorder2/app/models', __FILE__)) { Dir["*.rb"] }
    @classes = []

    # Dir['app/models/**/*.*'].map{|f| f.gsub('app/models/', '')}
    Dir["#{Rails.root}/app/models/**/*.*"].each do |class_name|
      @classes << class_name.split('/').last.sub(/\.rb$/,'').camelize.constantize
    end
    
    #select { |k| k.ancestors.include?(ActiveRecord::Base) && k.connection.table_exists?(k.table_name) }
    @classes.select! { |c| c.respond_to?('table_name') }
    
    @classes
  end 
  
  def list
    models = {}
    
    classes.each do |klass| 
      ar_ancestors = active_record_ancestors(klass)
      
      path_until_here = []
      
      klass_path = ar_ancestors.any? ? ar_ancestors.reverse : [] 
      
      if ar_ancestors.any?
        if ar_ancestors.first.match('::') && ar_ancestors.length == 1
          klass_path = (ar_ancestors.first + "::" + klass.to_s.split('::').last).split('::')
        elsif ar_ancestors.first.match('::')    
          raise 'unimplemented'
        else
          klass_path += klass.to_s.split('::') 
        end
      else
        klass_path += klass.to_s.split('::')   
      end   
           
      klass_path.each do |element|
        path_until_here << element           
        eval("models['" + path_until_here.join("']['") + "'] ||= {}")
      end
    end
    
    models
  end
  
  def associations(key_constant, options = { parent: ''})
    options.assert_valid_keys(:parent)
    
    key_constant = key_constant(key_constant, options[:parent]) if key_constant.is_a?(String)
     
    association_collection = []
    columns = columns_for(key_constant)
    columns.any? and association_collection << "belongs_to: #{columns.join(', ')}"    
    super_active_record_ancestor_column = "#{get_super_active_record_ancestor(key_constant).split('::').last.underscore}_id"
    has_many = {}
    
    if models_with_columns[super_active_record_ancestor_column]
      has_many[:standard] = models_with_columns[super_active_record_ancestor_column].uniq      
    else
      has_many[:alias] = {}
      
      models_with_columns.keys.select{|c| c.match("#{super_active_record_ancestor_column}")}.each do |column|
        has_many[:alias][column] = models_with_columns[column]
      end
      
      has_many[:alias].empty? and has_many = {}
    end
    
    has_many_polymorphs = {}
    
    if key_constant.respond_to?('reflections')
      key_constant.reflections.values.select{|r| [:has_one, :has_many].include?(r.macro) && r.options.has_key?(:as) }.each do |reflection|        
        association = reflection.options[:class_name] ? reflection.options[:class_name] : reflection.name.to_s.classify
        has_many_polymorphs[association] = reflection.options[:as].to_s
      end
    end
    
    !has_many_polymorphs.empty? and has_many[:polymorphic] = has_many_polymorphs
    
    !has_many.empty? and association_collection << "has_many: #{has_many.inspect}"
    
    association_collection.any? ? " (#{association_collection.join(';')})" : ""
  end
  
  def columns_for(key_constant, options = {})
    options.assert_valid_keys(:parent)
    
    key_constant = key_constant(key_constant, options[:parent]) if key_constant.is_a?(String)
    
    columns = []
    
    begin
      columns = key_constant.columns.map(&:name).select{|c| c.match('_id') || c.match('type')}.sort
    rescue NoMethodError
      columns = []
    end
    
    columns
  end
  
  private
  
  def models_with_columns
    return @models_with_columns if @models_with_columns
    
    @models_with_columns = {}
    #result = []
    
    classes.each do |klass| 
      columns_for(klass).each do |column|
        @models_with_columns[column] ||= []
        @models_with_columns[column] << klass.to_s
      end 
      
=begin      
      klass.reflections.values.select{|r| r.macro == :has_many && r.options.has_key?(:as) }.each do |reflection|        
        [
          "#{reflection.options[:as].to_s}_type"#, "#{reflection.options[:as].to_s}_id"
        ].each do |column|
          @models_with_columns[column] ||= []
          @models_with_columns[column] << reflection.options[:class_name] ? reflection.options[:class_name] : reflection.name.classify
        end
      end
        
      result << [klass.to_s, klass.table_name, ar_ancestors].inspect
=end
    end
    
    #raise @models_with_columns.inspect
    
    #raise Customer.reflections.values.select{|r| r.macro == :has_many && r.options[:as] == :owner }.first.inspect
    #raise BaseValue.reflections.values.select{|r| r.macro == :belongs_to && r.options[:polymorphic] == true }.first.inspect
    
    #render :text => result.join('<br/>') and return
    
    @models_with_columns
  end
  
  def get_super_active_record_ancestor(key_constant)
    ancestors = active_record_ancestors(key_constant)
    ancestors.none? ? key_constant.name : ancestors.last
  end
  
  # TODO: move to ActiveRecord::Base ClassMethods
  def active_record_ancestors(klass)
    ar_ancestors = []
    
    klass.ancestors.map(&:to_s).uniq.each do |ancestor|
      next if (ancestor == klass.to_s || ancestor == 'ActiveRecord::Base')
      
      ancestor_constant = ancestor.constantize rescue nil
      
      ancestor_constant == nil and next
      
      !ancestor_constant.ancestors.map(&:to_s).include?('ActiveRecord::Base') and next
      
      ar_ancestors << ancestor
    end
      
    ar_ancestors  
  end 
  
  def key_constant(key, parent = '')
    key_was = key
    key_constant = nil
        
    begin
      key_constant = "#{parent}::#{key}".constantize
    rescue
      begin
        key_constant = key.constantize
        
        !key_constant.ancestors.map(&:to_s).include?('ActiveRecord::Base') and raise key + 'is not a ActiveRecord instance.'
      rescue
        if parent.blank? && !key.match('::')
          raise 'unexpected:' + key.inspect
        elsif !parent.blank? && !key.match('::')
          key = "#{parent}::#{key}"
        elsif !parent.blank? && key.match('::')
          raise "unexpected constellation of parent '#{parent}' and key '#{key}'"
        end
      
        # e.g. DynamicForm::BaseElement::CheckBox should be DynamicForm::CheckBox
        key = key.split('::')       
        root_module = key.shift
        klass = key.pop
        
        tries = []
        
        while key.any?
          begin
            key_constant_name = "#{root_module}::#{key.join('::')}::#{klass}"
            tries << key_constant_name
            key_constant = key_constant_name.constantize
          rescue
            key.pop
          end
          
          break
        end
        
        begin
          key_constant_name = "#{root_module}::#{klass}"
          tries << key_constant_name
          key_constant = key_constant_name.constantize
        rescue
        end
        
        key_constant.blank? and raise 'unexpected that class for key "' + key_was + '" (' + ok.inspect + ') not found by one of these tries: ' + tries.inspect
      end
    end
    
    key_constant
  end
end