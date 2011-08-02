# -*- coding: utf-8 -*-
class AdminController < ApplicationController
  before_filter :authenticate_admin!
  def impersonate
    if params[:username]
      user = nil
      begin
        user = User.find params[:username]
      rescue
        puts  "error"
      end

      if !user
        user = User.find_by_email params[:username]
      end
      if user
        flash[:notice] = user.name + "adına giriş yapıldı!"
        sign_out current_user
        sign_in_and_redirect user, :event => :authentication
      elsif
        flash.now[:notice] = "kullanıcı bulunamadı, buyuk kucuk harf vs hepsi onemli!"
      end

    end
  end

end
