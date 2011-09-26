Delayed::Job.auto_scale = true
if RAILS_ENV == 'production'
#   Delayed::Job.auto_scale_manager = :heroku
else
#   Delayed::Job.auto_scale_manager = :local
end
