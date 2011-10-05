class BvIndexRebuilder
  DEFAULT_OPTIONS = {
    "recreate_index" => false
  }
  def self.re_index options = {}
    options = DEFAULT_OPTIONS.merge options
    #recreate index
    if options["recreate_index"]
      BvSearch.recreate_index
    end

    #re-index all organizations
    puts "will re-index all organizations"
    Organization.all.each do |o|
      o.re_index
    end
    puts "done"
  end
end