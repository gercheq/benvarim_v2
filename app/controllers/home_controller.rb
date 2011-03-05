class HomeController < ApplicationController
  def index
    @available_organizations = Organization.all.collect  do |o| { :value => o.name, :id => o.id} end
  end

  def about
  end

  def help
  end

  def whats_benvarim
    @selected_tab = "nav-nedir"
  end

end
