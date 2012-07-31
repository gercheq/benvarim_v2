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
#    1 => {:definition => "Kurum sayfasını beğen(facebook)"},
#    2 => {:definition => "Proje sayfasını beğen(facebook)"},
#    3 => {:definition => "Bağış sayfasını beğen(facebook)"},
    4 => {:definition => "Yapılan toplam bağış"},
    5 => {:definition => "Kurum sayfasından yapılan toplam bağış"},
    6 => {:definition => "Proje sayfasından yapılan toplam bağış"},
    7 => {:definition => "Bağış sayfasından yapılan toplam bağış"},
    8 => {:definition => "Yeni açılan bagış sayfaları"}
  }

  public
  def self.get_all_tracking_actions
    return @tracking_actions
  end


  # No need to aggregate those actions for now, because we don't have traffic
  # So, we can query only, but at some point it would be great to have such a thing TODO(berkan)
  public
  def self.aggregate_daily_actions
  end

  public
  def self.record_action action_id, count=1, amount=0.0, args = {}
    return false if action_id.nil?

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
  def self.construct_args email = nil, object = nil
    result = {}
    
    if !email.nil?
      result = {:email=>email}.merge! result
    end

    return result if object.nil?

    if object.is_a? Page
      result = {:page_id=>object.id, :project_id => object.project.id, :organization_id => object.organization.id }.merge! result
    elsif object.is_a? Project
      result = {:project_id => object.id, :organization_id => object.organization.id }.merge! result
    elsif object.is_a? Organization
      result = {:organization_id => object.id }.merge! result
    end

    return result
  end

end