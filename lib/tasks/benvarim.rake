# -*- coding: utf-8 -*-
task :clean_emails_from_local_db => :environment do
  if Rails.env.production?
    puts "cannot clean emails on production"
    return
  end
  puts "cleaning user emails #{User.all.length}"
  User.all.each do |u|
    u.email = "dummy-u-#{u.to_param}@benvarim.com"
    u.save!
    puts u.email
  end

  puts "cleaning organization emails"
  Organization.all.each do |o|
    o.email = "dummy-o-#{o.to_param}@benvarim.com"
    o.contact_email = "dummy-oc-#{o.to_param}@benvarim.com"
    o.save!
    puts o.email
    puts o.contact_email
  end


  puts "cleaning payment emails"
  Payment.all.each do |p|
    p.email = "dummy-p-#{p.id}@benvarim.com"
    p.save!
    puts p.email
  end

  puts "cleaning tmp payment emails"
  TmpPayment.all.each do |p|
    p.email = "dummy-tp-#{p.id}@benvarim.com"
    p.save!
    puts p.email
  end
  puts "done!"
end

task :update_paypal_infos_with_sandbox => :environment do
  if Rails.env.production?
    puts "cannot change paypal info w/ sandbox in production"
    return
  end
  puts "updating paypal infos with environment"
  PaypalInfo.all.each do |pp|
    pp.paypal_user = ENV['PAYPAL_SANDBOX_USER']
    pp.paypal_id_token = ENV['PAYPAL_ID_TOKEN']
    pp.currency = ENV['PAYPAL_CURRENCY']
    pp.save
  end
end