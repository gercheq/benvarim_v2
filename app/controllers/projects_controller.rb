# -*- coding: utf-8 -*-
class ProjectsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :by_organization]
  before_filter :require_organization, :except => [:show, :index, :by_organization]
  uses_tiny_mce

  def index
    tag = params[:tag]
    if tag
      @projects = Project.tagged_with tag
    else
      @projects = Project.all
    end
    @tag = tag

  end

  def by_organization
    org = Organization.find(params[:id])
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
    @top_pages = @project.pages.where("pages.collected > 0").order("pages.collected DESC").limit(3)
    unless @project.can_be_donated?
      flash.now[:error] = @project.cant_be_donated_reason
    end
  end

  def new
    @project = Project.new
    begin
      @organization = Organization.find(params[:organization_id])
      @project.organization = @organization
    rescue
      @organizations = current_user.organizations.collect do |org|
        [org.name, org.id]
      end
    end
    @predefined_payments = []
  end

  def edit
    @project = Project.find(params[:id])
    if @project.organization.user != current_user
      flash[:notice] = "Sadece yöneticisi olduğunuz kurumların projelerini düzenleyebilirsiniz."
      redirect_to @project
    end
    @predefined_payments = @project.predefined_payments.where("NOT deleted")
  end

  def create
    begin
      @organization = current_user.organizations.find(params[:organization_id])
      @project = @organization.projects.build(params[:project])
    rescue
      #we know it cannot be created w/o organization but just to let things go
      #we create it
      @project = Project.new(params[:project])
    end
    @project.accepts_random_payment = true
    @predefined_payments = Array.new
    predefineds = params[:predefined] || []
    predefineds.each do |pp_data|
      #set disabled first
      pp_data[:disabled] = "on" == pp_data[:disabled]
      ppRecord = nil
      ppRecord = @project.predefined_payments.build(pp_data)
      @predefined_payments += [ppRecord]
    end
    begin
      Project.transaction do
        @predefined_payments.each do |ppRecord|
          ppRecord.save!
        end
        parse_end_time
        #save the project at the end for validations
        @project.set_tag_list_on(:visible, params[:visible_tags])
        @project.save!
        redirect_to(@project, :success => 'Proje yaratıldı.')
      end
    rescue
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
      flash[:notice] = "Sadece yöneticisi olduğunuz kurumların projelerini düzenleyebilirsiniz."
      redirect_to @project
    end
    @project.accepts_random_payment = true

    @predefined_payments = Array.new
    predefineds = params[:predefined] || []
    predefineds.each do |pp_data|
      #set disabled first
      pp_data[:disabled] = "on" == pp_data[:disabled]
      ppRecord = nil
      if pp_data[:id] && pp_data[:id].blank? == false #existing record
        ppRecord = @project.predefined_payments.find pp_data[:id]
        ppRecord.update_attributes pp_data
      else
        ppRecord = @project.predefined_payments.build(pp_data)
      end
      @predefined_payments += [ppRecord]
    end

    @deleted_predefineds = params[:deleted_predefined] || []

    begin
      Project.transaction do
        @predefined_payments.each do |ppRecord|
          ppRecord.save!
        end
        @deleted_predefineds.each do |pp_id|
          ppRecord = @project.predefined_payments.find pp_id
          ppRecord.deleted = true
          ppRecord.save!
        end
        parse_end_time
        @project.set_tag_list_on(:visible, params[:visible_tags])
        @project.update_attributes!(params[:project])
        return redirect_to(@project, :success => 'Proje kaydedildi.')
      end
    rescue
      render :action => "edit"
    end
  end

  def parse_end_time
    if !params[:project]
      return
    end
    #save the project at the end
    any_empty = false
    for i in (1..3)
      if params[:project]["end_time(#{i}i)"] == ""
        any_empty = true
      end
    end
    if any_empty
      for i in (1..3)
        params[:project]["end_time(#{i}i)"] = ""
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.organization.user != current_user
      flash[:error] = "Sadece yöneticisi olduğunuz kurumların projelerini düzenleyebilirsiniz."
      redirect_to @project
    end
    @project.active = false
    @project.save!
  end
end
