# -*- coding: utf-8 -*-
class OrganizationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  uses_tiny_mce
  def index
    @organizations = Organization.all
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def new
    @organization = Organization.new
  end

  def create
    current_user.organization = Organization.new(params[:organization])
    if current_user.save
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
