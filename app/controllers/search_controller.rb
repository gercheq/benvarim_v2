class SearchController < ApplicationController
  def index
    if params['k']
      @keyword = params['k']
    else
      @keyword = ""
    end
  end

  def id_redirect
    q = params[:id]
    obj = BvSearch.find_by_doc_id q
    if(obj)
      redirect_to obj
    else
      redirect_to search_path
    end
  end

end
