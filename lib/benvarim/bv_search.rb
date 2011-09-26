# -*- coding: utf-8 -*-
require 'rubygems'
require 'indextank'


class ActiveRecord::Base
  protected
  @@index_maps = {}
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
      puts "empty index map"
      return
    end
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
    #replace any tr characters for better ux
    data = data.inject({}) { |h, (k, v)| h[k] = BvSearch.clean_turkish_letters(v); h }
    #replace title with name
    if(data[:title] && !data[:name])
      data[:name] = data[:title]
      data.delete :title
    end
    BvSearch.index(self.class.name, data, variables)
  end
end
class BvSearch
  @@defaultIndex="test"
  @client = nil
  @index = nil

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
    index.document("#{class_name}.#{data[:id]}").add(data, params)
  end

  def self.clean_turkish_letters text
    #make it string!
    "#{text}".gsub(/[öığşüÖİĞŞÜ]/,{"ö" => "o", "ü" => "u", "ı" => "i", "ğ" => "g", "ş" => "s", "ü" => "u", "Ö" => "O", "Ü" => "U", "İ" => "I", "Ğ" => "G", "Ş" => "S", "Ü" => "U"})
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
end