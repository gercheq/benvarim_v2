# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20110122102239
#
# Table name: contact_forms
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  city              :string(255)
#  phone             :string(255)
#  email             :string(255)
#  organization      :string(255)
#  organization_role :string(255)
#  other             :text
#  created_at        :datetime
#  updated_at        :datetime
#

class ContactForm < ActiveRecord::Base
  validates :name, :presence => true, :length => {:minimum => 3, :maximum => 254}
  validates :email, :presence => true
  validate :validate_email

  def validate_email
    self.errors.add "email", "geçersiz" unless self.email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end
end
