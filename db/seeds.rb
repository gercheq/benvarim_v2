# -*- coding: utf-8 -*-
u1 = User.find_by_email "baslevent@gmail.com"
if u1.nil?
  u1 = User.create({
    :name => "Levent Baş",
    :email => "baslevent@gmail.com",
    :password => "test567"
  });
  u1.save!
end

u2 = User.find_by_email "rizao123sman@gmail.com"
if u2.nil?
  u2 = User.create({
    :name => "Osman Rıza",
    :email => "rizao123sman@gmail.com",
    :password => "test123"
  });
  u2.save!
end

u3 = User.find_by_email "gercekk@gmail.com"
if u3.nil?
  u3 = User.create({
    :name => "Gercek Karakus",
    :email => "gercekk@gmail.com",
    :password => "00198400"
  });
  u3.save!
end

unless u1.organizations.length > 0
  org = u1.organizations.build({
    :name => "Nesin Vakfı",
    :description_html => "Nesin Vakfi aciklama yazisi",
    :email => "nesin@vakif.com",
    :contact_email => "nesin@vaikf.com"
  })
  org.active = true;
  org.save!
end
org = u1.organizations[0]
unless u2.organizations.length > 0
  org2 = u2.organizations.build({
    :name => "TEMA",
    :description_html => "toprak kaymasin yagmur yagsin",
    :email => "nesin2@vakif.com",
    :contact_email => "nesin2@vaikf.com"
  })
  org2.active = true;
  org2.save!
end
org2 = u2.organizations[0]

if org.projects.length < 2
  org.projects.build({
    :name => "Toprak Ana",
    :description => "Bu projede amac toprak ana",
    :active => true
  })
  org.save!
end

if u3.pages.length < 1
  u3.pages.build({
    :organization_id => org2.id,
    :description_html => "ben de para <b>toplamak</b> isterim",
    :title => "para toplamak en guzeli",
    :goal => 10,
    :project_id => org2.projects[0].id,
    :active => true


  })
  u3.pages[0].save!
end

if u3.pages[0].payments.length < 1
  page = u3.pages[0]
  page.payments.build({
    :name => "Ahmet Balcı",
    :note => "helal bea!",
    :email => "ahmetbalci@hotmail.com",
    :project_id => page.project_id,
    :amount => 10,
    :organization_id => page.organization_id
  })
  page.payments.build({
    :name => "Selami Mustafaoglu",
    :note => "ben de para vereyim",
    :email => "mustafaselami@hotmail.com",
    :project_id => page.project_id,
    :amount => 5,
    :organization_id => page.organization_id
  })

  page.collected = 15

  page.save!
end