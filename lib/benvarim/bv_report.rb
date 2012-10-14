class BvReport
  DEFAULT_TO_DATE = DateTime.current.to_s
  DEFAULT_FROM_DATE = DateTime.current.beginning_of_month
  DEFAULT_MONTH_INTERVAL = 12
  
  INTERVAL_6MONTH = 1;
  INTERVAL_LAST_MONTH = 2;
  INTERVAL_LIFE_TIME = 3;

  public
  def self.validate_dates from=nil, to=nil
    if to.nil? || to == ""
      to = DEFAULT_TO_DATE
    end

    if from.nil? || from == ""
      from = DEFAULT_FROM_DATE
    end


    if (from <=> to) == 1
      tmp = from;
      from = to.to_datetime;
      to = tmp.to_datetime.end_of_day;
    end

    return :from=>from, :to=>to
  end
  
  def self.get_date_interval type
    to = nil
    from = nil
    
    if type == INTERVAL_LAST_MONTH
      from = DateTime.current.prev_month.beginning_of_month
      to = from.end_of_month
    elsif type == INTERVAL_6MONTH
      from = (DateTime.current.months_ago 6).beginning_of_month
      to = (from.months_since 5).end_of_month
    elsif type == INTERVAL_LIFE_TIME
      from = DateTime.strptime("1", "%s")
      to = DateTime.current
    end
    
    return :from => from, :to => to
  end
  
  def self.get_stats organization, arranged_dates
    page_stats = Page.all(
      :select => "COUNT(1) AS total, COUNT(DISTINCT user_id) AS user, SUM(goal) AS goal",
      :conditions =>["pages.organization_id=? AND pages.created_at BETWEEN ? AND ?",organization.id, arranged_dates[:from], arranged_dates[:to]],
      :group => "organization_id"
    )

    payment_stats = Payment.all(
      :select =>"CASE WHEN page_id IS NULL THEN 'f_organization' ELSE 'f_page' END AS source, COUNT(1) AS total, COUNT(DISTINCT email) AS user, SUM(amount) AS collected",
      :conditions =>["payments.organization_id=? AND payments.created_at BETWEEN ? AND ?",organization.id,arranged_dates[:from], arranged_dates[:to]],
      :group => "source"
    )
    
    support_stats = Support.all(
      :select => "COUNT(1) AS total",
      :conditions =>["supports.organization_id=? AND supports.created_at BETWEEN ? AND ?", organization.id, arranged_dates[:from], arranged_dates[:to]]
    )
    
    return :page_stats => page_stats, :payment_stats => payment_stats, :support_stats => support_stats
  end
end