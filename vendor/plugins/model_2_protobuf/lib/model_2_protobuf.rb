require 'erb'

#
# The message definition determined by the column in the Model
#
class MessageDefinition
  attr_reader :fields,:message_name,:parent
  
  def initialize(model_name,parent)
    @parent = parent
    @message_name = model_name
    @fields = []
  end
  
  def build
    tag_count = 0
    model = @message_name.constantize
    model.columns().each do |c|
      unless c.name == 'id' or c.name.ends_with?("_id")
        @fields << "#{rule(c.null)} #{type(c.type)} #{c.name} = #{tag_count += 1} #{default(c.default)}"
      end
    end
    model.reflect_on_all_associations(:has_many).each do |a|
      relation_type = a.name.to_s.capitalize.camelize.singularize
      relation_name = a.name.to_s
      # Check the assoc is included in our list models in the config file. If it is
      # include it, otherwise ignore the relationship
      if parent.models.include?(relation_type)
        @fields << "repeated #{relation_type} #{relation_name} = #{tag_count +=1}"
      end
    end
    
  end
  
  def default(v)
    unless v.nil?
      "[default = #{v}]"
    else
      ""
    end
  end
  
  def rule(v)
    case v
      when true: "optional"
      when false: "required"
    end
  end
  
  def type(v)
    case v
      when :integer: "uint64"
      when :decimal: "double"
      when :text: "string"
      when :string: "string"
      when :datetime: "string"
      when :float: "float"
      when :boolean: "bool"
    end
  end
end

# Main builder class
class ProtoFileBuilder
  attr_reader :models, :messages
  
  def initialize(model_names)
    @models = []
    model_names.each do |name|
      begin
        name.capitalize.camelize.constantize.class
        @models << name.capitalize.camelize
      rescue
        puts "Error: skipping '#{name}' it does not appear to be a model in this application."
        puts "Check the protocolbuffer.yml"
      end
    end
    @messages = []
  end
  
  def build
    @models.each do |type|
      m = MessageDefinition.new(type,self)
      m.build
      @messages << m
    end
  end
  
end
