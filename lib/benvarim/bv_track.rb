class BvTrack
  @@super_params = nil

  @@NO_USER_DISTINCT_ID = "abcdef"
  @@distinct_id = nil

  public
  def self.track event_name, properties = nil
    Delayed::Job.enqueue TrackJob.new(event_name, properties, @@super_params)
  end

  def self.set_supers session = nil, req = nil, current_user = nil
    @@super_params = self.get_env req
    @@super_params["token"] = ENV['MIXPANEL_TOKEN']
    @@distinct_id = self.get_distinct_id session, current_user
    session["mixpanel_distinct_id"] = [@@distinct_id]
    @@super_params["distinct_id"] = @@distinct_id

    user_supers = self.get_user_supers current_user
    @@super_params.merge! user_supers
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

  def self.get_distinct_id session, current_user
    unless current_user.nil?
      return current_user.id
    end
    unless session.nil?
      if session["mixpanel_distinct_id"].nil?
        session["mixpanel_distinct_id"] = generate_distinct_id
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
       return
       {
         :logged_in => false
       }
    end
    {
      :logged_in => true,
      :user_name => user.name,
      :user_birthday => user.birthday,
      :user_created_at => user.created_at
    }
  end
  def self.get_env req
    puts "XXXX #{req}"
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