# -*- coding: utf-8 -*-
u1 = User.find_by_email "baslevent@gmail.com"
if u1.nil?
  u1 = User.create({
    :name => "Levent Baş",
    :email => "baslevent@gmail.com",
    :password => "test123"
  });
  u1.save!
end

u2 = User.find_by_email "rizaosman@gmail.com"
if u2.nil?
  u2 = User.create({
    :name => "Osman Rıza",
    :email => "rizaosman@gmail.com",
    :password => "test123"
  });
  u2.save!
end

u3 = User.find_by_email "selamimimimimi@gmail.com"
if u3.nil?
  u3 = User.create({
    :name => "Selami Şaho",
    :email => "selamimimimimi@gmail.com",
    :password => "test123"
  });
  u3.save!
end

org = Organization.new({
  :name => "Nesin Vakfı",
  :description_html => "Ben <b>eşşek</b> sen eşşek onlar eşşek"
})
org.user_id = u1.id
org.save!
u1.organization = org
u1.save!

org2 = Organization.new({
  :name => "Temaaaaa",
  :description_html => "toprak kaymasin yagmur yagsin"
})
org2.user_id = u2.id
org2.save!
u2.organization = org2
u2.save!

u2.organization.projects.build({
  :name => "Toprak Ana",
  :description => "Bu projede amac toprak ana"
})
u2.organization.save!
u3.pages.build({
  :organization_id => u2.organization.id,
  :description_html => "ben de para <b>toplamak</b> isterim",
  :title => "para toplamak en guzeli",
  :goal => 10,
  :project_id => u2.organization.projects[0].id
})
u3.pages[0].save!