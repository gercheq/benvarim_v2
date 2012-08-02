class BvReport
  DEFAULT_TO_DATE = Date.today.to_s
  DEFAULT_MONTH_INTERVAL = 12

  public
  def self.validate_dates from=nil, to=nil
    if to.nil? || to == ""
      to = DEFAULT_TO_DATE
    end

    if from.nil? || from == ""
      from = Date.strptime(to, "%Y-%m-%d").months_ago(DEFAULT_MONTH_INTERVAL).to_s
    end


    if (from <=> to) == 1
      tmp = from;
      from = to;
      to = tmp;
    end

    return :from=>from, :to=>to
  end
end