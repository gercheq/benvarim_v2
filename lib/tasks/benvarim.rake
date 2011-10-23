# -*- coding: utf-8 -*-
task :clean_emails_from_local_db => :environment do
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