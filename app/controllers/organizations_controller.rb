# -*- coding: utf-8 -*-
class OrganizationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  uses_tiny_mce
  def index
    @organizations = Organization.all
  end

  def show
    @organization = Organization.find(params[:id])
    @top_pages = @organization.pages.where("pages.collected > 0").order("pages.collected DESC").limit(3)
    @projects = @organization.projects
    if !@organization.can_be_donated?
      flash.now[:notice] = "Kurum bilgileri Benvarım.com tarafından henüz onaylanmadığı için bağış yapamazsınız"
    end
  end

  def new
    #if the current user has an organization, redirect to its page
    unless current_user.organization.nil?
      redirect_to current_user.organization
    end
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])
    @organization.user = current_user
    if @organization.save
      redirect_to(current_user.organization, :notice => "Sivil Toplum Kuruluşu Yaratıldı")
    else
      render :new
    end
  end

  def edit
    @organization = current_user.organization
    redirect_to :action => :new if @organization.nil?
  end

  def update
    @organization = current_user.organization
    redirect_to :action => :new if @organization.nil?

    if @organization.update_attributes(params[:organization])
      redirect_to(@organization, :notice => 'Bigiler başarıyla kaydedildi.')
    else
      render :action => "edit"
    end

  end
end
