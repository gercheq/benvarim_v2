# -*- coding: utf-8 -*-
class OrganizationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  uses_tiny_mce
  def index
    @organizations = Organization.order("active desc, logo_updated_at desc")
  end

  def show
    @organization = Organization.find(params[:id])
    @top_pages = @organization.pages.order("pages.collected DESC").limit(5)
    # @top_pages = @organization.pages.where("pages.collected > 0").order("pages.collected DESC").limit(3)
    @projects = @organization.projects
    # DISABLING ERROR MESSAGES ON ORGANIZATION PAGES FOR NOW
    # MIGHT BE RENABLED IN THE FUTURE
    # if !@organization.can_be_donated?
    #   flash.now[:error] = @organization.cant_be_donated_reason
    # end
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = current_user.organizations.build(params[:organization])
    @organization.set_tag_list_on(:visible, params[:visible_tags])
    if @organization.save
      redirect_to(@organization, :success => "Sivil Toplum Kuruluşu yaratıldı.")
    else
      render :new
    end
  end

  def edit
    @organization = current_user.organizations.find(params[:id])
    redirect_to :action => :new if @organization.nil?
  end

  def update
    @organization = current_user.organizations.find(params[:id])
    redirect_to :action => :new if @organization.nil?
    @organization.set_tag_list_on(:visible, params[:visible_tags])
    if @organization.update_attributes(params[:organization])
      redirect_to(@organization, :success => 'Bigiler başarıyla kaydedildi.')
    else
      render :action => "edit"
    end

  end
end
