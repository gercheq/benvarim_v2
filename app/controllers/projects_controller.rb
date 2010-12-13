# -*- coding: utf-8 -*-
class ProjectsController < ApplicationController
  before_filter :authenticate_organization!, :except => [:show, :index, :by_organization]

  def index
    @projects = Project.all
  end

  def our_projects
    redirect_to :action => :by_organization, :id => current_organization.id
  end

  def by_organization
    org = Organization.find_by_id(params[:id])
    puts org.id
    if org
      @projects = org.projects.all
    else
      @projects = Array.new
    end


    respond_to do |format|
        format.js
        format.html
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def edit
    @project = current_organization.projects.find(params[:id])
  end

  def create
    @project = current_organization.projects.build(params[:project])

    if @project.save
      redirect_to(@project, :notice => 'Proje yaratıldı.')
    else
      render :action => "new"
    end
  end

  def update
    @project = current_organization.projects.find(params[:id])
    if @project.update_attributes(params[:project])
      redirect_to(@project, :notice => 'Proje kaydedildi.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @project = current_organization.projects.find(params[:id])
    @project.destroy
  end
end
