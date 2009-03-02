
namespace :protobuf do
  
  desc "Create a protocol buffer definition file for a given set of models"
  task :create => [:environment] do
    $LOAD_PATH << "#{File.dirname(__FILE__)}/../lib"
    require 'yaml'
    require "model_2_protobuf"
  
    cnfg = YAML.load_file("#{RAILS_ROOT}/config/protocolbuffer.yml")
    models = cnfg["models"]
    out_file = cnfg["output_file"]
 
    p = ProtoFileBuilder.new(models)
    p.build

    f = File.open("#{RAILS_ROOT}/protocolbuffer/template/proto_template.txt.erb",'r').read
    template = ERB.new(f)
    @msgs = p.messages
    File.new(File.join(RAILS_ROOT,"protocolbuffer",out_file),'w').write(template.result(binding))
  end
  
end

