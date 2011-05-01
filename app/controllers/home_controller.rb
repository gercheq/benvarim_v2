class HomeController < ApplicationController
  def index
    @available_organizations = Organization.available_organizations_simple
    @top_pages = Page.where("pages.collected > 0").order("pages.collected DESC").limit(3)
    @top_projects = Project.order("collected DESC").limit(3)
  end

  def about
  end

  def help
  end

  def nasil_calisir
    @selected_tab = "nav-nedir"
    @available_organizations = Organization.available_organizations_simple
  end

  def nedir
    @selected_tab = "nav-nedir"
    @available_organizations = Organization.available_organizations_simple
  end

end
