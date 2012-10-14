desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  #since we use free daily cron, it will only run once a day.
  begin
    UserMailer.send_daily_payment_emails
  rescue
  end
  begin
    OrganizationMailer.send_daily_mail
  rescue
  end
  begin
    UserMailer.send_5_days_inactivity_email
  rescue
  end
  begin
    PaymentMailer.send_5_days_goal_not_reached_email
  rescue
  end
  day_of_year = Time.new.yday % 3
  if day_of_year % 3 == 0
    # re-create search index once in three days to catch up
    BvIndexRebuilder.re_index({"recreate_index" => false, "sync" => false})
  end
end
