class IndexJob
  include HerokuDelayedJobAutoscale::Autoscale
  attr_accessor :class_name, :id, :index_map
  def initialize map
    puts "dsa"
    self.id = map[:id]
    self.class_name = map[:class_name]
    self.index_map = map[:index_map]
  end

  def perform
    puts "performing"
    puts self.class_name
    puts self.id
    obj = self.class_name.constantize.find(self.id)
    result = obj.re_index(self.index_map)
    if( !result)
      raise "index request did not succeed"
    end
    puts "end"
  end
end