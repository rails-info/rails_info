class RailsInfo::Data
  class << self
    def update_multiple(data)
      collection = {}

      data.each do |element|
        klass, id = element.split(';')
        collection[klass] ||= []
        collection[klass] << id
      end
  
      collection.each do |klass,ids|
        klass.constantize.delete(ids)
      end
    end
  end
  
  def initialize
    @rails_info_model = ::RailsInfo::Model.new
  end
  
  def last_objects
    klasses = @rails_info_model.classes
    objects = {}
        
    klasses.each do |klass|
      sort_field = [:updated_at, :created_at].select{|v| klass.columns.map{|c|c.name.to_sym}.include?(v)}.first
         
      raise NotImplementedError.new("No known sort fields found in attribute keys: #{object.attributes.keys.inspect}") if sort_field.blank?
      
      klass.limit(10).each do |object|
        objects[object.send(sort_field).to_i] = object.attributes
        objects[object.send(sort_field).to_i][:class] = object.class
      end
    end

    row_sets = []
    last_class = ""
    last_objects = []

    objects.keys.sort {|x,y| y <=> x }.each do |sort_value|
      if last_class != "" && objects[sort_value][:class] != last_class
        row_sets << last_objects
        last_objects = []
      end

      last_objects << objects[sort_value]
      last_class = objects[sort_value][:class]
    end

    row_sets << last_objects
    
    row_sets
  end
end