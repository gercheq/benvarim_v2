# -*- coding: utf-8 -*-
class ProjectsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :by_organization]
  before_filter :require_organization, :except => [:show, :index, :by_organization]
  uses_tiny_mce

  def index
    @projects = Project.all
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
    @organization = Organization.find_by_id(params[:organization_id])
    if @organization
      @project.organization = @organization
    else
      @organizations = current_user.organizations.collect do |org|
        [org.name, org.id]
      end
    end
  end

  def edit
    @project = Project.find(params[:id])
    if @project.organization.user != current_user
      flash[:notice] = "Sadece yöneticisi olduğunuz kurumların projelerini düzenleyebilirsiniz"
      redirect_to @project
    end
  end

  def create
    @organization = current_user.organizations.find_by_id(params[:organization_id])
    if(@organization)
      @project = @organization.projects.build(params[:project])
    else
      #we know it cannot be created w/o organization but just to let things go
      #we create it
      @project = Project.new(params[:project])
    end
    if @project.save
      redirect_to(@project, :notice => 'Proje yaratıldı.')
    else
      if @organization
        # @project.organization = @organization
      else
        @organizations = current_user.organizations.collect do |org|
          [org.name, org.id]
        end
      end
      render :action => "new"
    end
  end

  def update
    @project = Project.find(params[:id])
    if @project.organization.user != current_user
      flash[:notice] = "Sadece yöneticisi olduğunuz kurumların projelerini düzenleyebilirsiniz"
      redirect_to @project
    end

    if @project.update_attributes(params[:project])
      redirect_to(@project, :notice => 'Proje kaydedildi.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.organization.user != current_user
      flash[:notice] = "Sadece yöneticisi olduğunuz kurumların projelerini düzenleyebilirsiniz"
      redirect_to @project
    end
    @project.active = false
    @project.save!
  end
end
