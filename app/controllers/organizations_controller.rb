class OrganizationsController < ApplicationController
  before_filter :authenticate_organization!, :except => [:show]
  def index
  end

  def create
  end

  def edit
  end

  def show
  end

end
