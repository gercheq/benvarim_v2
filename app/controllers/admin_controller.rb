# -*- coding: utf-8 -*-
class AdminController < ApplicationController
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

end
