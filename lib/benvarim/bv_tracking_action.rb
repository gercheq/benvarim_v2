# -*- coding: utf-8 -*-
class BvTrackingAction
  
  LIKED_ORGANIZATION = 1
  LIKED_PROJECT = 2
  LIKED_PAGE = 3

  FUNDED_ORGANIZATION = 4
  FUNDED_ORGANIZATION_FROM_ORGANIZATION_PAGE = 5
  FUNDED_ORGANIZATION_FROM_PROJECT_PAGE = 6
  FUNDED_ORGANIZATION_FROM_USER_PAGE = 7

  CREATED_PAGE_FOR_ORGANIZATION = 8

  @tracking_actions = {
    1 => {:definition => "Kurum sayfasini begen(facebook)", :single_row => false },
    2 => {:definition => "Proje sayfasini begen(facebook)", :single_row => false },
    3 => {:definition => "Kullanici sayfasini begen(facebook)", :single_row => false },
    4 => {:definition => "Toplanan toplam bagis", :single_row => false },
    5 => {:definition => "Organizasyon sayfasindan toplanan toplam bagis", :single_row => false },
    6 => {:definition => "Proje sayfasindan toplanan toplam bagis", :single_row => false },
    7 => {:definition => "Kullanici sayfasindan toplanan toplam bagis", :single_row => false },
    8 => {:definition => "Yeni acilan bagis sayfalari", :single_row => true },
  }

  public
  def self.get_all_tracking_actions
    return @tracking_actions
  end


  # No need to aggregate those actions for now, because we don't have that much traffic
  # So, we can query only, but at some point it would be great to have such a thing TODO(berkan)
  public
  def self.aggregate_daily_actions
  end

  public
  def self.record_action action_id, count=1, amount=0.0, args = {}
    return false if action_id.nil?
    
    # Update the existing one, this is silly
    if @tracking_actions[action_id][:single_row] && action = TrackingAction.find(:first, :conditions => args)
      action.count = count
      action.amount = amount

      return action.save
    end

    # Add default count and amount, do not override if exits
    args = {:count=>count, :amount=>amount}.merge! args

    # We have all the info, now we can save
    # This is my own something.relation.build function, maybe one day i change it :) TODO(berkan)
    action = TrackingAction.new
    action.action_id = action_id

    args.each do |k,v|
      action.send "#{k}=", v if action.has_attribute? k
    end

    return action.save
  end

  public
  def self.construct_args email = nil, page = nil, project = nil, organization = nil
    result = {}
    
    if !email.nil?
      result = {:email=>email}.merge! result
    end

    if !page.nil?
      result = {:page_id=>page.id, :project_id => page.project.id, :organization_id => page.organization.id }.merge! result
    elsif !project.nil?
      result = {:project_id => project.id, :organization_id => project.organization.id }.merge! result
    elsif !organization.nil?
      result = {:organization_id => organization.id }.merge! result
    end

    return result
  end

end