class SitemapController < ApplicationController
  layout nil

  def index
    @organizations = Organization.find(:all, :order => "id desc")
    @projects = Project.find(:all, :order => "id desc")
    @pages = Page.find(:all, :order => "id desc")
    @users = User.find(:all, :order => "id desc")
    @today = Time.now.to_date
    headers["Content-Type"] = "text/xml"
    # set last modified header to the date of the latest entry.
    headers["Last-Modified"] = @organizations[0].logo_updated_at.httpdate
  end
end
