# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  def index
  end

  def me
    redirect_to current_user
  end
  def show
    @user = User.find(params[:id])
    @available_organizations = Organization.available_organizations_simple
  end

  def edit
    @user = User.find(params[:id])
    if @user != current_user
      redirect_to :action => :show
    end
  end

  def update
    @user = User.find(params[:id])
    puts params.to_yaml
    if @user != current_user
      return redirect_to :action => :show
    end
    if @user.update_attributes(params[:user])
      redirect_to(@user, :success => 'Bigiler başarıyla kaydedildi.')
    else
      render :action => "edit"
    end

  end
end
