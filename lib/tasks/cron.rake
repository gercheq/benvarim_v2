desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  #since we use free daily cron, it will only run once a day.
  UserMailer.send_daily_payment_emails
  OrganizationMailer.send_daily_mail
  UserMailer.send_5_days_inactivity_email
end
