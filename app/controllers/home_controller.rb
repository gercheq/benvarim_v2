class HomeController < ApplicationController
  def index
    @available_organizations = Organization.available_organizations_simple
    @top_pages = Page.filter_out_hidden.where("pages.collected > 0 AND active").order("pages.updated_at DESC").limit(4)
    rows = 4
    @top_projects = Project.featureds.limit rows #Project.where("active").order("collected DESC").limit(rows)
    if @top_projects.length < rows
      ids = [-1] + @top_projects.collect do |tp| tp.id end
      limit = rows - @top_projects.length
      @more_projects = Project.filter_out_hidden.where("active AND id NOT IN(#{ids.join(',')})").order("collected DESC").limit(limit)
      @top_projects += @more_projects
    end
  end

  def about
  end

  def help
  end

  def maintenance
    render :layout => false
  end

  def paypal
    render :layout => false
  end

  def nasil_calisir
    @selected_tab = "nav-nedir"
    @available_organizations = Organization.available_organizations_simple
  end

  def nedir
    @selected_tab = "nav-nedir"
    @available_organizations = Organization.available_organizations_simple
    @top_pages = Page.where("pages.collected > 0").order("pages.collected DESC").limit(4)
    @top_projects = Project.order("collected DESC").limit(4)
  end

end
