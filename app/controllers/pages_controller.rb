# -*- coding: utf-8 -*-
class PagesController < ApplicationController

  before_filter :authenticate_user!, :except => [:show, :index, :partial_payments]
  uses_tiny_mce :options => {
    :height => 450
  }

  @@payment_page_size = 15

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
    @pages = Page.where("active").order("updated_at desc")
  end

  def my_pages
    @pages = current_user.pages.all
  end

  def show
    @page = Page.find(params[:id])
    if !@page.can_be_donated?
      flash.now[:error] = @page.cant_be_donated_reason
    end
    @include_more_link = params[:paginate] ? true : false
    @payments = fetch_payments_page

    @show_fb_like_send = (@page.id > 9 || params[:fb]) ? true : false

    @post_donate = flash[:success] == true || params[:pd] == "1"
  end

  def fetch_payments_page(start=nil)
    query = @page.payments
    if(start)
      query = query.where("id < ?", start)
    end
    payments = query.order("id desc").limit(@include_more_link ? @@payment_page_size + 1 : 250)
    @more = @include_more_link && payments.length > @@payment_page_size ? true : false
    if @more
      payments.pop
    end
    return payments
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
    parse_end_time
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
    parse_end_time
    @page = current_user.pages.find(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to(@page, :success => 'Bağış sayfası güncellendi.')
    else
      add_organization_list
      add_project_list (@page.organization.nil? ? nil : @page.organization)
      render :action => "edit"
    end
  end

  def parse_end_time
    if !params[:page]
      return
    end
    #save the project at the end
    any_empty = false
    for i in (1..3)
      if params[:page]["end_time(#{i}i)"] == ""
        any_empty = true
      end
    end
    if any_empty
      for i in (1..3)
        params[:page]["end_time(#{i}i)"] = ""
      end
    end
  end

  def partial_payments
    @include_more_link = true
    @page = Page.find(params[:id])
    if !@page.can_be_donated?
      flash.now[:error] = @page.cant_be_donated_reason
    end
    puts params[:start]
    @payments = fetch_payments_page params[:start]
    render :layout => false
  end
end
