class ReportController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
  
  def performance
    # TODO(berkan): Useless copy paste
    # I think I have a bad copy paste habit

    @organization = Organization.find params[:organization_id]
    @arranged_dates = BvReport.validate_dates params[:from], params[:to]
    
    stats = BvReport.get_stats @organization, @arranged_dates

    @count_new_page = 0
    @total_fund = 0.0
    @total_funder = 0
    @total_project_count = @organization.projects.where("active=? AND created_at<?", true, @arranged_dates[:to]).count
    @supporter = 0

    unless stats[:page_stats].nil? || stats[:page_stats].empty?
      @count_new_page = stats[:page_stats].first.total.to_i
    end
    
    unless stats[:support_stats].nil? || stats[:support_stats].empty?
      @supporter = stats[:support_stats].first.total.to_i
    end
    
    unless stats[:payment_stats].nil? || stats[:payment_stats].empty?
      stats[:payment_stats].each do |s|
        @total_fund += s.collected.to_f
        @total_funder += s.total.to_i
      end
    end

    date_last_month = BvReport.get_date_interval BvReport::INTERVAL_LAST_MONTH
    stats = BvReport.get_stats @organization, date_last_month

    @count_new_page_lm = 0
    @total_fund_lm = 0.0
    @total_funder_lm = 0
    @total_project_count_lm = @organization.projects.where("active=? AND created_at<?", true, date_last_month[:to]).count
    @supporter_lm = 0

    unless stats[:page_stats].nil? || stats[:page_stats].empty?
      @count_new_page_lm = stats[:page_stats].first.total.to_i
    end
    
    unless stats[:support_stats].nil? || stats[:support_stats].empty?
      @supporter_lm = stats[:support_stats].first.total.to_i
    end
    
    unless stats[:payment_stats].nil? || stats[:payment_stats].empty?
      stats[:payment_stats].each do |s|
        @total_fund_lm += s.collected.to_f
        @total_funder_lm += s.total.to_i
      end
    end

    date_6m = BvReport.get_date_interval BvReport::INTERVAL_6MONTH
    stats = BvReport.get_stats @organization, date_6m

    @count_new_page_6m = 0
    @total_fund_6m = 0.0
    @total_funder_6m = 0
    @total_project_count_6m = @organization.projects.where("active=? AND created_at<?", true, date_6m[:to]).count
    @supporter_6m = 0

    unless stats[:page_stats].nil? || stats[:page_stats].empty?
      @count_new_page_6m = stats[:page_stats].first.total.to_i
    end
    
    unless stats[:support_stats].nil? || stats[:support_stats].empty?
      @supporter_6m = stats[:support_stats].first.total.to_i
    end
    
    unless stats[:payment_stats].nil? || stats[:payment_stats].empty?
      stats[:payment_stats].each do |s|
        @total_fund_6m += s.collected.to_f
        @total_funder_6m += s.total.to_i
      end
    end

    date_lt = BvReport.get_date_interval BvReport::INTERVAL_LIFE_TIME
    stats = BvReport.get_stats @organization, date_lt

    @count_new_page_lt = 0
    @total_fund_lt = 0.0
    @total_funder_lt = 0
    @total_project_count_lt = @organization.projects.where("active=? AND created_at<?", true, date_lt[:to]).count
    @supporter_lt = 0

    unless stats[:page_stats].nil? || stats[:page_stats].empty?
      @count_new_page_lt = stats[:page_stats].first.total.to_i
    end
    
    unless stats[:support_stats].nil? || stats[:support_stats].empty?
      @supporter_lt = stats[:support_stats].first.total.to_i
    end
    
    unless stats[:payment_stats].nil? || stats[:payment_stats].empty?
      stats[:payment_stats].each do |s|
        @total_fund_lt += s.collected.to_f
        @total_funder_lt += s.total.to_i
      end
    end
    
    render :layout => false
  end
  
  def details
    @organization = Organization.find params[:organization_id]
    @arranged_dates = BvReport.validate_dates params[:from], params[:to]
    
    @pages = Page.all(
      :select => "pages.*, count(payments.id) as total, MIN(payments.created_at) as min_date, MAX(payments.created_at) as max_date",
      :joins => "LEFT JOIN payments ON pages.id = payments.page_id",
      :conditions =>["pages.organization_id=? AND ((pages.created_at BETWEEN ? AND ?) OR (payments.created_at BETWEEN ? AND ?))",
                            @organization.id, @arranged_dates[:from], @arranged_dates[:to], @arranged_dates[:from], @arranged_dates[:to]],
      :group => "pages.id"
    )
    
    @payments = Payment.all(
      :conditions => ["payments.organization_id=? AND payments.created_at BETWEEN ? AND ?", @organization.id, @arranged_dates[:from], @arranged_dates[:to]]
    )

    render :layout => false
  end
end
