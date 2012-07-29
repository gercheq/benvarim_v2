class BvReport
  DEFAULT_TO_DATE = Date.today.to_s
  DEFAULT_MONTH_INTERVAL = 12

  FUNDED_ORGANIZATION = [
    BvTrackingAction::LIKED_ORGANIZATION,
    BvTrackingAction::LIKED_PROJECT,
    BvTrackingAction::LIKED_PAGE,
    BvTrackingAction::FUNDED_ORGANIZATION,
    BvTrackingAction::FUNDED_ORGANIZATION_FROM_ORGANIZATION_PAGE,
    BvTrackingAction::FUNDED_ORGANIZATION_FROM_PROJECT_PAGE,
    BvTrackingAction::FUNDED_ORGANIZATION_FROM_USER_PAGE,
    BvTrackingAction::CREATED_PAGE_FOR_ORGANIZATION
  ]

  public
  def self.validate_dates from=nil, to=nil
    if to.nil?
      to = DEFAULT_TO_DATE
    end

    if from.nil?
      from = Date.strptime(to, "%Y-%m-%d").months_ago(DEFAULT_MONTH_INTERVAL).to_s
    end


    if (from <=> to) == 1
      tmp = from;
      from = to;
      to = tmp;
    end

    return :from=>from, :to=>to
  end

  public
  def self.get_all_global_stats organization, from, to, stats = FUNDED_ORGANIZATION
    result = TrackingAction.all(
      :select => "action_id as action, COUNT(DISTINCT email) as user, SUM(count) as count, SUM(amount) as amount",
      :conditions => "organization_id=#{organization.id} AND action_id IN (#{stats.join(",")}) AND created_at BETWEEN '#{from}' AND '#{to}'",
      :group => "action_id, organization_id"
    )

    result = Hash[*result.map{|r| [r.action.to_i, r]}.flatten]
    return result
  end

  public
  def self.get_all_page_stats pages
    page_ids = pages.collect {|p| p.id}

    result = Payment.all(
      :select => "page_id as page_id, COUNT(DISTINCT email) as user, MIN(created_at) as mindate, MAX(created_at) as maxdate",
      :conditions => "page_id IN (#{page_ids.join(",")})",
      :group => "page_id"
    )
    
    result = Hash[*result.map{|r| [r.page_id.to_i, r]}.flatten]
    return result
  end
  
end