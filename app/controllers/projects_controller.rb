# -*- coding: utf-8 -*-
class ProjectsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :by_organization]
  before_filter :require_organization, :except => [:show, :index, :by_organization]
  uses_tiny_mce

  def index
    @projects = Project.all
  end

  def our_projects
    @projects = current_user.organization.projects.all
  end

  def by_organization
    org = Organization.find_by_id(params[:id])
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
    unless @project.can_be_donated?
      flash.now[:notice] = "Proje aktif olmadığı için bağış toplayamazsınız."
    end
  end

  def new
    @project = Project.new
  end

  def edit
    @project = current_user.organization.projects.find(params[:id])
  end

  def create
    @project = current_user.organization.projects.build(params[:project])

    if @project.save
      redirect_to(@project, :notice => 'Proje yaratıldı.')
    else
      render :action => "new"
    end
  end

  def update
    @project = current_user.organization.projects.find(params[:id])
    if @project.update_attributes(params[:project])
      redirect_to(@project, :notice => 'Proje kaydedildi.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @project = current_user.organization.projects.find(params[:id])
    @project.destroy
  end
end
