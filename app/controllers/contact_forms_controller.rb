# -*- coding: utf-8 -*-
class ContactFormsController < ApplicationController
  # GET /contact_forms
  # GET /contact_forms.xml
  def index
    redirect_to :new_contact_form
  end
  # GET /contact_forms/new
  # GET /contact_forms/new.xml
  def new
    @contact_form = ContactForm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact_form }
    end
  end

  # POST /contact_forms
  # POST /contact_forms.xml
  def create
    @contact_form = ContactForm.new(params[:contact_form])
    if @contact_form.valid?
      ContactMailer.contact_benvarim(@contact_form).deliver
      flash[:notice] = "Mesajınız tarafımıza ulaştı. En kısa sürede sizinle iletişime geçeceğiz. Teşekkürler"
      return redirect_to :action => :index
    else
      render :new
    end
  end
end
