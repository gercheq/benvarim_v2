class HomeController < ApplicationController
  def index
    @available_organizations = Organization.available_organizations_simple
  end

  def about
  end

  def help
  end

  def nasil_calisir
    @selected_tab = "nav-nedir"
    @available_organizations = Organization.available_organizations_simple
  end

end
