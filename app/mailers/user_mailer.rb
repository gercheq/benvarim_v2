# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def signup user
    @user = user
    mail(:to => user.email,
         :subject => "Benvarim.com'a Hoşgeldin!",
         "X-SMTPAPI" => '{"category": "user_signup"}')
  end

  def dailymail(page,payments)
	@page = page
	@payments = payments

    mail(:to => page.user.email,
        :bcc => "team@benvarim.com",
        :subject => "Benvarim - %s isimli sayfanıza bugün yapılan bağışlar" % [page.title],
        "X-SMTPAPI" => '{"category": "user_daily"}')
  end

  def send_daily_payment_emails
    now = Time.now.in_time_zone("Istanbul")
    UserMailer.send_payment_email_for_days((now - 1.day),now)
  end
  def send_payment_email_for_days(start_date, end_date)
    query = Page.includes(:payments).where("payments.created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
    query.each do |page|
      payments = page.payments.where("created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
      if payments.length
        UserMailer.dailymail(page, payments).deliver
      end
    end
  end

  def new_page page_id
    @page = Page.find page_id
    @user = @page.user
    if @page.aggregated_hidden
      # hidden page, don't even bother
      return
    end
    mail(:to => @user.email,
         :bcc => "team@benvarim.com",
         :subject => "#{@user.name}, Bağış Sayfanı Yarattın. Tebrikler!",
         "X-SMTPAPI" => '{"category": "user_newpage"}')
  end

  def  new_page_3_days page_id
    @page = Page.find page_id
    @user = @page.user
    @subject = "#{@user.name}, bağış sayfan nasıl gidiyor?"
    mail(:to => @user.email,
         :bcc => "team@benvarim.com",
         :subject => @subject,
         "X-SMTPAPI" => '{"category": "user_newpage_third_day"}')
  end

  def new_page_last_7_days page_id
    @page = Page.find page_id
    @user = @page.user
    @subject = "#{@user.name}, sayfanı başarıya ulaştırmak için 7 gün kaldı!"
    mail(:to => @user.email,
         :bcc => "team@benvarim.com",
         :subject => @subject,
         "X-SMTPAPI" => '{"category": "user_newpage_last_7_days"}')
  end


  def send_inactivity_for_days(now, period)
    start_date = now - period.day
    end_date = now
    donated_during_period = Page.includes(:payments).where("payments.created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
    donated_before_period = Page.includes(:payments).where("payments.created_at between ? and ?", (start_date - 1.day).strftime('%Y-%m-%d'), start_date.strftime('%Y-%m-%d'))
    pages = donated_before_period - donated_during_period
    pages.each do |p|
      if(p.can_be_donated? && p.did_reach_goal? == false)
        Delayed::Job.enqueue MailJob.new("UserMailer", "page_inactivity", p)
      end
    end
  end

  def send_5_days_inactivity_email
    now = Time.now.in_time_zone("Istanbul")
    UserMailer.send_inactivity_for_days(now, 5)
  end

  def page_inactivity page
    @page = page
    @user = page.user
    mail(:to => @user.email,
         :bcc => "team@benvarim.com",
         :subject => "Bağış sayfanı tekrar canlandırmak için yapman gerekenler",
         "X-SMTPAPI" => '{"category": "user_pageinactivity"}')
  end
  
  def new_page_7_days page_id
    @page = Page.find page_id
    @user = @page.user
    @organization = @page.organization

    return unless @page.can_be_donated?
    
    mail(:to => @user.email,
         :bcc => "team@benvarim.com",
         :subject => "#{@user.name}, Mektup Var!-#{@organization.name})",
         "X-SMTPAPI" => '{"category": "user_newpage_7_days"}')
  end
  
  def new_page_last_3_days page_id
    @page = Page.find page_id
    @user = @page.user
    @subject = "#{@user.name}, 3 Günde Neler Değişir Neler..."
    
    return unless @page.can_be_donated?
    
    mail(:to => @user.email,
         :bcc => "team@benvarim.com",
         :subject => @subject,
         "X-SMTPAPI" => '{"category": "user_newpage_last_3_days"}')
  end
  
  def page_goal_failed page_id
    @page = Page.find page_id
    @user = @page.user
    @subject = "#{@user.name}, Bu Sefer Olmadı, Bir Dahaki Sefere..."

    return unless @page.can_be_donated?
    
    mail(:to => @user.email,
         :bcc => "team@benvarim.com",
         :subject => @subject,
         "X-SMTPAPI" => '{"category": "user_page_goal_failed"}')
  end
  
end
