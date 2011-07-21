# -*- coding: utf-8 -*-
class PagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  uses_tiny_mce :options => {
    :height => 450
  }

  def add_organization_list
    @organizations = Organization.available_organizations.collect do |org|
      [org.name, org.id]
    end
  end

  def add_project_list organization = nil
    if organization.nil?
      @projects = Array.new
    else
      @projects = organization.projects.all.collect do |p|
        [p.name, p.id]
      end
    end

  end

  def index
    @pages = Page.all
  end

  def my_pages
    @pages = current_user.pages.all
  end

  def show
    @page = Page.find(params[:id])
    if !@page.can_be_donated?
      flash.now[:error] = "Sayfa aktif olmadığı için bağış yapamazsınız."
    end
    @payments = @page.payments.order("id desc")
    
    @show_fb_like_send = params[:fb] ? true : false
  end

  def new
    @page = Page.new

    if params[:org_id]
      begin
        @organization = Organization.find params[:org_id]
        return redirect_to new_page_for_organization_path(@organization)
      rescue
      end
    end
    if params[:organization_id]
      @organization = Organization.find params[:organization_id]
    end
    if params[:project_id]
      begin
        @project = Project.find params[:project_id]
        if(@project)
          @organization = @project.organization
        end
      rescue
      end
    end

    @page.project = @project
    @page.organization = @organization
    add_organization_list
    add_project_list @organization
  end

  def edit
    @page = current_user.pages.find(params[:id])
    add_organization_list
    add_project_list @page.organization
  end

  def create
    @page = current_user.pages.build(params[:page])
    if @page.save
      redirect_to(@page, :success => 'Bağış sayfası yaratıldı.')
    else
      add_organization_list
      add_project_list (@page.organization.nil? ? nil : @page.organization)
      render :action => "new"
    end
  end

  def update
    @page = current_user.pages.find(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to(@page, :success => 'Bağış sayfası güncellendi.')
    else
      add_organization_list
      add_project_list (@page.organization.nil? ? nil : @page.organization)
      render :action => "edit"
    end
  end
end
