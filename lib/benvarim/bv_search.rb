# -*- coding: utf-8 -*-
require 'rubygems'
require 'indextank'


class ActiveRecord::Base
  protected
  @@index_maps = {}

  public
  def re_index change_map=nil
    #TODO
    #send change map instead of whole data.
    puts "reindexing #{self.class.name}"
    change_map = @@index_maps[self.class.name]
    puts @@index_maps
    if(!change_map)
      puts "change map is nil " + self.class.name
      return
    end
    data = {}
    variables = {}
    if(change_map[:fields])
      change_map[:fields].each do |f|
        data[f] = self.send(f)
      end
    end
    if(change_map[:variables])
      change_map[:variables].each do |k,v|
        val = self.send(v)
        if val.nil?
          #ommit
        elsif val.is_a?(TrueClass)
          variables[k] = 1
        elsif val.is_a?(FalseClass)
          variables[k] = 0
        elsif val.is_a?(String)
          variables[k] = val.to_f
        else
          variables[k] = val
        end
      end
    end
    add_to_index(data, variables)
  end

  protected
  def self.index_map index_map
    if(!index_map[:fields])
      raise "cannot index w/o fields!"
    end
    puts "in index map"
    @@index_maps[self.name] = index_map
    puts @@index_maps
    # BvSearchObserver.add_class self.name, index_map
  end

  def after_save
    puts "after save #{self.class.name}"
    puts @@index_maps
    index_map = @@index_maps[self.class.name]
    if(! index_map)
      puts "empty index map #{self.class.name}"
      return
    end
    #take a copy, dont edit the original
    index_map = index_map.clone
    puts "fields we have #{index_map}"
    #check if any of the fields is changed
    index_map[:fields].keep_if { |f| self.respond_to?("#{f}_changed?") ? self.send("#{f}_changed?") : true }
    if(index_map[:variables])
      index_map[:variables].keep_if { |f| self.respond_to?("#{f}_changed?") ? self.send("#{f}_changed?") : true }
    end
    if(index_map[:fields].length || (index_map[:variables] && index_map[:variables].length))
      puts "putting job"
      Delayed::Job.enqueue IndexJob.new({:class_name => self.class.name, :id => self.id, :index_map => index_map})
      puts "putting job done"
    end
    puts "changed fields: #{index_map.to_json}"

  end


  def add_to_index data, variables = nil
    data = data || {}
    data[:id] = self.id
    #delete nil, indextank does not love them
    data.delete_if{|key,value| value.blank?}
    human_readable_name = nil
    #replace title with name
    if(data[:title] && !data[:name])
      data[:name] = data[:title]
      data.delete :title
    end
    if(!data[:text])
      data[:text] = data[:name]
    end
    human_readable_name = data[:name]

    #replace any tr characters for better ux
    data = data.inject({}) { |h, (k, v)| h[k] = BvSearch.clean_turkish_letters(v); h }
    #human_readable_name may include turkish chars
    data["human_readable_name"] = human_readable_name

    puts "indexing data:#{self.class.name} #{data} #{variables}"
    BvSearch.index(self.class.name, data, variables)
  end
end
class BvSearch
  @@defaultIndex="test"
  @client = nil
  @index = nil

  #consts
  VAR_CAN_BE_DONATED=0
  VAR_COLLECTED=1
  #variables end

  def self.search query, indexName=nil
    index = get_index indexName
    return index.search(self.clean_turkish_letters(query), :fetch => [:id, :title, :name])
  end

  def self.init_test
    # Obtain an IndexTank client
    index = get_index
    begin
        # Add documents to the index
        index.document("abc").add({ :text => "some text here" })
        index.document("def").add({ :text => "some other text" })
        index.document("ghj").add({ :text => "something else here" })

        # Search the index
        results = index.search("some")

        print "#{results['matches']} documents found\n"
        results['results'].each { |doc|
            print "docid: #{doc['docid']}\n"
        }
    rescue
        print "Error: ",$!,"\n"
    end
  end

  def self.index class_name, data, variables
    index = get_index
    params = {
      :categories => {:type => class_name},
      :variables => variables
    }

    #remove nil params
    params.delete_if{|key,value| value.blank?}
    doc_id = "#{class_name}.#{data[:id]}"
    # res = index.batch_insert([obj ])
    puts "indexing id #{doc_id} data #{data} params #{params}"
    res = index.document(doc_id).add(data, params)

    puts "index reuslt #{res}"
    res == 200
  end

  def self.clean_turkish_letters text
    #make it string!
    "#{text}".gsub(/[öığşüÖİĞŞÜ]/,{"ö" => "o", "ü" => "u", "ı" => "i", "ğ" => "g", "ş" => "s", "ü" => "u", "Ö" => "O", "Ü" => "U", "İ" => "I", "Ğ" => "G", "Ş" => "S", "Ü" => "U"})
  end

  def self.get_default_index_name
    return @@defaultIndex
  end

  private
  def self.get_client
    @client ||= IndexTank::Client.new(ENV['INDEXTANK_API_URL']) #ON DEV goes to y-benvarim index
    @client
  end

  def self.get_index name=nil
    name = name || @@defaultIndex
    client = self.get_client
    client.indexes(name)
  end

  def self.recreate_index
    puts "recreating index"
    index = self.get_index
    index.delete
    puts "deleted index"
    client = self.get_client
    index = client.indexes @@defaultIndex
    index.add :public_search => true

    cnt = 20
    while not index.running? and cnt > 0
      puts "index is not running yet, will wait .5 seconds"
      sleep 0.5
      cnt = cnt - 1
    end
    if cnt > 0
      puts "index re-created"
    else
      puts "could not recreate index"
    end
  end

end