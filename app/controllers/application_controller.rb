# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
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
end
