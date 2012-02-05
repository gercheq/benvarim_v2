# -*- coding: utf-8 -*-
class OrganizationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :support, :support_landing]
  before_filter :require_facebook_connect!, :only => [:support, :support_landing]
  uses_tiny_mce

  def index
    # Old index
    # @organizations = Organization.order("active desc, logo_updated_at desc")

    tag = params[:tag]
    if tag
      @organizations = Organization.tagged_with tag
    else
      @organizations = Organization.all
    end
    @tag = tag

  end



  def show
    @organization = Organization.find(params[:id])
    # DISABLING ERROR MESSAGES ON ORGANIZATION PAGES FOR NOW
    # MIGHT BE RENABLED IN THE FUTURE
    # if !@organization.can_be_donated?
    #   flash.now[:error] = @organization.cant_be_donated_reason
    # end
    @top_pages = @organization.top_pages
    @projects = @organization.projects
    if current_user
      @support = current_user.supports.find_by_organization_id @organization.id
    end

    @post_support = flash[:post_support] == 1


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

  def support_landing
    @organization = Organization.find params[:organization_id]
    @user = User.find params[:user_id]
    session[:organization_support_referer] = {
      :user_id => @user.id,
      :organization_id => @organization.id
    }
    puts "SETTING SESSION #{session[:organization_support_referer]}"
    redirect_to organization_support_path(@organization)
  end

  def support
    @reference = session[:organization_support_referer]
    @organization = Organization.find params[:id]
    @support = Support.find_by_user_id_and_organization_id current_user.id, @organization.id
    @current_user = current_user
    if !@support
      @support = @organization.supports.build ({
        :user_id => current_user.id,
        :score => 1
      })
      begin
        Support.transaction do
          if @reference != nil
            if @reference[:organization_id] == @organization.id && @reference[:user_id] != current_user.id
              @referer = User.find @reference[:user_id]
              @support.referer_id = @referer.id

              user_support = Support.find_by_user_id_and_organization_id @reference[:user_id], @organization.id
              if user_support
                user_support.score += 1
                user_support.save!
              end
            else
              puts "REFERENCE ID IS NOT VALID"
            end
          else
            puts "DID NOT FIND REFERER INFORMATION"
          end
          @support.save!
          if @reference
            session[:organization_support_referer] = nil
          end
        end
      rescue Exception => e
        puts e
      end
    end

    @top_pages = @organization.top_pages
    @projects = @organization.projects

    # DISABLE ERROR MESSAGE FOR NON-ACTIVE ORGANIZATIONS
    # if !@organization.can_be_donated?
    #   flash.now[:error] = @organization.cant_be_donated_reason
    # end
    flash[:post_support] = 1
    redirect_to @organization
  end
end
