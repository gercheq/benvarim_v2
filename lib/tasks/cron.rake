desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  if Time.now.hour == 0 # run at midnight
    @pages = Page.all
    @pages.each do |page|
      # UserMailer.dailymail(page).deliver
    end
  end
end
