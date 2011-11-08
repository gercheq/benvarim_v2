# -*- coding: utf-8 -*-
class AdminController < ApplicationController
  before_filter :authenticate_admin!
  def impersonate
    if params[:k]
      user = nil
      obj = BvSearch.find_by_doc_id params[:k]
      if obj
        #try to find user
        if obj.is_a?(User)
          user = obj
        else
          begin
            user = obj.send("user")
          rescue
          end
        end
      end
      if user
        flash[:notice] = user.name + "adına giriş yapıldı!"
        sign_out current_user
        sign_in_and_redirect user, :event => :authentication
      else
        flash.now[:notice] = "kullanıcı bulunamadı, buyuk kucuk harf vs hepsi onemli!"
      end

    end
  end

  def organizations
    @organizations = Organization.all
  end

  def pages
    @pages = Page.order("created_at DESC")
  end

  def edit_page
    page = Page.find params[:id]
    active = params[:active]

    if active && page.active
      flash[:notice] = "e zaten #{page.title} aktif :/"
    elsif !active && !page.active
      flash[:notice] = "e zaten #{page.title} pasif :/"
    elsif active
      page.active = true
      page.save!
      flash[:notice] = "#{page.title} aktiflendi, hayirli ugurlu olsun."
    else
      page.active = false
      page.save!
      flash[:notice] = "#{page.title} kapatildi, cok uzuldum :("
    end
    redirect_to :action => :pages
  end

  def edit_organization
    org = Organization.find params[:id]
    active = params[:active]

    if active && org.active
      flash[:notice] = "e zaten #{org.name} aktif :/"
    elsif !active && !org.active
      flash[:notice] = "e zaten #{org.name} pasif :/"
    elsif active
      org.active = true
      org.save!
      flash[:notice] = "#{org.name} aktiflendi, hayirli ugurlu olsun."
    else
      org.active = false
      org.save!
      flash[:notice] = "#{org.name} kapatildi, cok uzuldum :("
    end
    redirect_to :action => :organizations
  end

end
