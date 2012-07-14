# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  before_filter :check_maintenance
  before_filter :set_session_on_bv_feature
  protect_from_forgery
protected
  ROBOTS = ["googlebot","twitterbot", "facebookexternalhit", "google.com/bot.html", "facebook.com/externalhit_uatext.php", "tweetmemebot", "sitebot", "msnbot", "robot", "bot"]
  def is_robot?
    ROBOTS.include? request.env["HTTP_USER_AGENT"]
  end

  def require_organization
    unless user_signed_in? && current_user.organizations.length > 0
      flash[:notice] = "İlk önce bir kurum eklemelisiniz"
      redirect_to new_organization_path
    end
  end

  def authenticate_admin!
    authenticate_user!
    unless ["berkankisaoglu@gmail.com", "yboyar@gmail.com", "baslevent@gmail.com", "gercekk@gmail.com", "melis.okan@gmail.com"].include? current_user.email
      redirect_to root_url
    end
  end

  def require_facebook_connect!
    user = current_user
    puts user
    if !user || !user.fb_connect
      store_location_for_sign_in
      redirect_to user_omniauth_authorize_path :facebook
    end
  end

  def store_location_for_sign_in
    # hacking devise, not good but could not find a workaround
    session["user_return_to"] = request.fullpath
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

  def set_session_on_bv_feature
    BvFeature.set_session session
  end
end
