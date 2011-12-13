# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  before_filter :check_maintenance
  protect_from_forgery
protected
  def require_organization
    unless user_signed_in? && current_user.organizations.length > 0
      flash[:notice] = "İlk önce bir kurum eklemelisiniz"
      redirect_to new_organization_path
    end
  end

  def authenticate_admin!
    authenticate_user!
    unless ["yboyar@gmail.com", "baslevent@gmail.com", "gercekk@gmail.com", "melis.okan@gmail.com"].include? current_user.email
      redirect_to root_url
    end
  end

  def check_maintenance
    if self.controller_name == "home" && self.action_name == "maintenance"
      return
    end
    start_time = Time.utc(2011, 12, 13, 20, 55)
    end_time = Time.utc(2011, 12, 13, 22)
    now = Time.now.in_time_zone("UTC")
    if now > start_time && now < end_time
      redirect_to maintenance_url
    end
    #
  end
end
