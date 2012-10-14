class BvIndexRebuilder
  DEFAULT_OPTIONS = {
    "recreate_index" => false,
    "sync" => false
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
      if options["sync"]
        o.re_index
      else
        o.index_after_save
      end
    end
    puts "will re-index all projects"
    Project.all.each do |p|
      if options["sync"]
        p.re_index
      else
        p.index_after_save
      end
    end

    puts "will re-index all pages"
    Page.all.each do |p|
      if options["sync"]
        p.re_index
      else
        p.index_after_save
      end
    end
    puts "done"
  end
end