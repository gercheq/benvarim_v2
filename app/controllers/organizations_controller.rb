# -*- coding: utf-8 -*-
class OrganizationsController < ApplicationController
  before_filter :authenticate_organization!, :except => [:show, :index]
  uses_tiny_mce
  def index
    @organizations = Organization.all
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def edit
    @organization = current_organization
  end

  def update
    @organization = current_organization


    if @organization.update_attributes(params[:organization])
      redirect_to(@organization, :notice => 'Bigiler başarıyla kaydedildi.')
    else
      render :action => "edit"
    end

  end
end
