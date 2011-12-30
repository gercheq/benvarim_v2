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
end
