class BvTrack
  @@super_params = nil

  @@NO_USER_DISTINCT_ID = "abcdef"
  @@distinct_id = nil

  public
  def self.track event_name, properties = nil
    Delayed::Job.enqueue TrackJob.new(event_name, properties, @@super_params)
  end

  def self.track_with_user user, event_name, properties = nil
    supers = self.create_supers nil, nil, user
    supers[:logged_in] = false
    Delayed::Job.enqueue TrackJob.new(event_name, properties, supers)
  end

  def self.set_supers session = nil, req = nil, current_user = nil
    @@super_params = create_supers session, req, current_user
    @@distinct_id = @@super_params['distinct_id']
    unless session.nil? || current_user.nil?
      if session["SET_MIXPANEL_USER_DATA"].nil? || session["SET_MIXPANEL_USER_DATA"] != current_user.id
        Delayed::Job.enqueue TrackUserJob.new(current_user.id)
        session["SET_MIXPANEL_USER_DATA"] = current_user.id
      end
    end

  end




  def self.supers_as_json
    if @@super_params.nil?
      return {
        :distinct_id => self.distinct_id
      }.to_json
    end
    return @@super_params.to_json
  end

  def self.distinct_id
    if @@distinct_id.nil?
      @@distinct_id = self.generate_distinct_id
    end
    @@distinct_id
  end

  private

  def self.create_supers session = nil, req = nil, current_user = nil
    supers = self.get_env req
    supers["distinct_id"] = self.get_distinct_id session, current_user

    unless session.nil?
      session["mixpanel_distinct_id"] = supers["distinct_id"]
    end
    user_supers = self.get_user_supers current_user
    supers.merge! user_supers
    supers
  end

  def self.get_distinct_id session, current_user
    unless current_user.nil?
      return current_user.id
    end
    unless session.nil?
      if session["mixpanel_distinct_id"].nil?
        session["mixpanel_distinct_id"] = self.generate_distinct_id
      end
      return session["mixpanel_distinct_id"]
    end
    @@NO_USER_DISTINCT_ID
  end

  def self.generate_distinct_id
    (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  end

  def self.get_user_supers user
    if user.nil?
       {
         :logged_in => false
       }
    else
      {
        :logged_in => true,
        :user_name => user.name,
        :user_birthday => user.birthday,
        :user_created_at => user.created_at
      }
    end
  end
  def self.get_env req
    unless req.nil?
      return {
        'REMOTE_ADDR' => req.env['REMOTE_ADDR'],
        'HTTP_X_FORWARDED_FOR' => req.env['HTTP_X_FORWARDED_FOR'],
        'is_request' => true
      }
    end
    {
      'is_request' => false
    }
  end
end