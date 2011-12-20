class HomeController < ApplicationController
  def index
    @available_organizations = Organization.available_organizations_simple
    @top_pages = Page.where("pages.collected > 0 AND active").order("pages.updated_at DESC").limit(4)
    @top_projects = Project.where("active").order("collected DESC").limit(4)
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
