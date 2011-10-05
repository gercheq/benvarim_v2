class SearchController < ApplicationController
  def index
    if params['k']
      @results = BvSearch.search params['k']
    end
  end

end
