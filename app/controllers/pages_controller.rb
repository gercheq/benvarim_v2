# -*- coding: utf-8 -*-
class PagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  uses_tiny_mce

  def add_organization_list
    @organizations = Organization.all.collect do |org|
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
  end

  def new
    @page = Page.new
    if params[:organization_id]
      @organization = Organization.find_by_id params[:organization_id]
    end
    if params[:project_id]
      @project = Project.find_by_id params[:project_id]
      if(@project)
        @organization = @project.organization
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
      redirect_to(@page, :notice => 'Sayfa yaratıldı.')
    else
      add_organization_list
      add_project_list (@page.organization.nil? ? nil : @page.organization)
      render :action => "new"
    end
  end

  def update
    @page = current_user.pages.find(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to(@page, :notice => 'Sayfa güncellendi.')
    else
      add_organization_list
      add_project_list (@page.organization.nil? ? nil : @page.organization)
      render :action => "edit"
    end
  end

  def destroy
    @page = current_user.pages.find(params[:id])
    @page.destroy
    respond_to do |format|
      redirect_to(pages_url)
    end
  end
end
