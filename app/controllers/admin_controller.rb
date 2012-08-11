# -*- coding: utf-8 -*-
class AdminController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
  before_filter :authenticate_admin!
  def impersonate
    if params[:k]
      user = nil
      obj = BvSearch.find_by_doc_id params[:k]
      if obj
        #try to find user
        if obj.is_a?(User)
          user = obj
        else
          begin
            user = obj.send("user")
          rescue
          end
        end
      end
      if user
        flash[:notice] = user.name + "adına giriş yapıldı!"
        sign_out current_user
        sign_in_and_redirect user, :event => :authentication
      else
        flash.now[:notice] = "kullanıcı bulunamadı, buyuk kucuk harf vs hepsi onemli!"
      end

    end
  end

  def organizations
    @organizations = Organization.all
  end

  def pages
    @pages = Page.order("created_at DESC")
  end

  def projects
    @projects = Project.order("created_at DESC")
  end

  def edit_project
    project = Project.find params[:id]
    project.active = params[:active] == "1"
    project.hidden = params[:hidden] == "1"
    project.save!
    flash[:notice] = "Değişiklikler kaydedildi #{project.name} aktif: #{project.active} gizli: #{project.hidden}"
    respond_to do |format|
      format.html {redirect_to :action => :projects}
      format.json { render :json => {
        :name => project.name,
        :hidden => project.hidden,
        :aggregated_hidden => project.aggregated_hidden
        } }
    end
  end

  def edit_page
    page = Page.find params[:id]
    page.active = params[:active] == "1"
    page.hidden = params[:hidden] == "1"
    page.save!
    flash[:notice] = "Değişiklikler kaydedildi #{page.title} aktif: #{page.active} gizli: #{page.hidden}"
    respond_to do |format|
      format.html {redirect_to :action => :pages}
      format.json { render :json => {
        :title => page.title,
        :active => page.active?,
        :hidden => page.hidden,
        :aggregated_hidden => page.aggregated_hidden
        } }
    end

  end

  def user_list
    users = User.connection.execute("SELECT id, id||'- '||name as label FROM users ORDER BY name ASC")
    respond_to do |format|
      format.json {
        render :json => {
          :users => users.collect do |u| u end
        }
      }
    end
  end

  def project_list
    projects = Project.connection.execute("SELECT id, cached_slug as label FROM projects ORDER BY cached_slug ASC").collect do |p| p end
    respond_to do |format|
      format.json {
        render :json => {
          :projects => projects
        }
      }
    end
  end

  def organization_list
    organizations = Organization.connection.execute("SELECT id, cached_slug as label FROM organizations ORDER BY cached_slug ASC").collect do |o| o end
    respond_to do |format|
      format.json {
        render :json => {
          :organizations => organizations
        }
      }
    end
  end

  def featured
  end

  def edit_featured
    act =  params[:act]
    errors = Array.new
    if act && act[:doc_id] && act[:action]
      # do changes
      obj = BvSearch.find_by_doc_id act[:doc_id]
      if obj
        if act[:action] == "delete"
          obj.tag_list_on(:hidden).delete "featured"
          obj.save!
        elsif act[:action] == "add"
          obj.tag_list_on(:hidden).add "featured"
          obj.save!
        end
      end
    end

    projects = Project.featureds.select("projects.id, name, cached_slug")
    organizations = Organization.featureds.select("organizations.id, name, cached_slug")
    respond_to do |format|
      format.json {
        render :json => {
          :projects => projects,
          :organizations => organizations
        }
      }
    end
  end

  def edit_organization
    org = Organization.find params[:id]
    org.set_tag_list_on(:hidden, params[:hidden_tags])
    org.set_tag_list_on(:visible, params[:visible_tags])
    org.active = params[:active] == "1"
    org.hidden = params[:hidden] == "1"
    if params[:uid]
      u = User.find_by_id params[:uid]
      if u
        org.user = u
      end
    end
    org.save!
    flash[:notice] = "değişiklikler kaydedildi"
    respond_to do |format|
      format.html {redirect_to :action => :organizations}
      format.json { render :json => {
        :name => org.name,
        :active => org.active?,
        :visible_tags => org.visible_tags,
        :hidden_tags => org.hidden_tags,
        :uid => org.user.id,
        :user_name => org.user.name

        } }
    end
  end

  def export_emails
    emails = Array.new
    emails += User.find(:all, :select => "email").collect do |x| x.email end
    emails += Organization.find(:all, :select => "contact_email").collect do |x| x.contact_email end
    emails += TmpPayment.find(:all, :select => "email").collect do |x| x.email end
    emails += ContactForm.find(:all, :select => "email").collect do |x| x.email end
    emails += Bvlog.where("content like '%payer_email%'").select("SUBSTRING(content FROM 'payer_email\"\:\"([A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})') as content").limit(5).collect do |x| x.content end
    emails  = emails.uniq
    @emails = emails

  end

  def stats
    @monthly_payments = Payment.connection.execute("select to_char(created_at, 'YYYY-MM') as month, sum(amount), count(*), count(DISTINCT(organization_id)), count(DISTINCT(project_id)), count(DISTINCT(page_id)) from payments group by month order by month desc").values
    total_payments = Payment.connection.execute("select 'toplam', sum(amount), count(*), count(DISTINCT(organization_id)), count(DISTINCT(project_id)), count(DISTINCT(page_id)) from payments").values
    @monthly_payments = total_payments + @monthly_payments
    new_users = User.connection.execute("select to_char(created_at, 'YYYY-MM') as month, count(*) from users group by month order by month desc").values
    total_users = User.connection.execute("select 'toplam', count(*) from users").values
    new_users = new_users + total_users
    @new_users = {}
    new_users.each do |n|
      @new_users[n[0]] = n[1]
    end

    fb_connects = FbConnect.connection.execute("select to_char(created_at, 'YYYY-MM') as month, count(*) from fb_connects group by month order by month desc").values
    total_fb_connects = User.connection.execute("select 'toplam', count(*) from fb_connects").values
    fb_connects = fb_connects + total_fb_connects
    @fb_connects = {}
    fb_connects.each do |f|
      @fb_connects[f[0]] = f[1]
    end

  end

  def features
    @features = BvFeature::TEST_FEATURES
  end

  def enable_feature
    BvFeature.enable_feature params[:name]
    redirect_to :action => :features
  end

  def disable_feature
    BvFeature.disable_feature params[:name]
    redirect_to :action => :features
  end

  def paypal_ec
    @organization = Organization.find params[:id]
    if @organization.paypal_info.nil?
      @organization.paypal_info = PaypalInfo.new
    else

    end
    @paypal_info = @organization.paypal_info

    if request.post?
      valid = true
      @paypal_info.use_express = params[:use_express] == "1"
      @paypal_info.currency = params[:currency]
      if params["update_info"] == "1"
        @paypal_info.update_express_info(params[:login], params[:password], params[:signature])
      end
      # @organization.paypal_info = @paypal_info
      if valid && @paypal_info.save
        flash.now[:success] = "bilgiler kaydedildi"
        Delayed::Job.enqueue MailJob.new("AdminMailer", "paypal_ec_updated_notifier", [current_user.id, @paypal_info.id])
      else
        flash.now[:error] = @paypal_info.errors
      end
    end

    @params = params
  end

  def report
    @organization = Organization.find params[:id]
    @arranged_dates = BvReport.validate_dates params[:from], params[:to]

    page_stats = Page.all(
      :select => "COUNT(1) AS total, COUNT(DISTINCT user_id) AS user, SUM(goal) AS goal",
      :conditions =>["pages.organization_id=? AND pages.created_at BETWEEN ? AND ?",@organization.id, @arranged_dates[:from], @arranged_dates[:to]],
      :group => "organization_id"
    )

    payment_stats = Payment.all(
      :select =>"CASE WHEN page_id IS NULL THEN 'f_organization' ELSE 'f_page' END AS source, COUNT(1) AS total, COUNT(DISTINCT email) AS user, SUM(amount) AS collected",
      :conditions =>["payments.organization_id=? AND payments.created_at BETWEEN ? AND ?",@organization.id,@arranged_dates[:from], @arranged_dates[:to]],
      :group => "source"
    )

    @pages = Page.all(
      :select => "pages.*, count(payments.id) as total, MIN(payments.created_at) as min_date, MAX(payments.created_at) as max_date",
      :joins => "LEFT JOIN payments ON pages.id = payments.page_id",
      :conditions =>["pages.organization_id=?", @organization.id],
      :group => "pages.id"
    )

    @count_new_page = 0
    @amount_new_page_goal = 0.0
    @total_fund = 0.0
    @total_fund_from_page = 0.0
    @total_fund_from_org = 0.0
    @total_funder = 0

    unless page_stats.nil? || page_stats.empty?
      @count_new_page = page_stats.first.total.to_i
      @amount_new_page_goal = page_stats.first.goal.to_f
    end
    
    unless payment_stats.nil? || payment_stats.empty?
      payment_stats.each do |s|
        @total_fund += s.collected.to_f
        @total_fund_from_page = s.collected.to_f if s.source == "f_page"
        @total_fund_from_org = s.collected.to_f if s.source == "f_organization"
        @total_funder += s.total.to_i
      end
    end

    @t_count = 0
    @t_collected = 0
    @t_goal = 0
  end

end
