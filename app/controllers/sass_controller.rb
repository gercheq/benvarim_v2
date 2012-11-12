# -*- coding: utf-8 -*-
class SassController < ApplicationController
  def sass
    respond_to do |format|
      format.css { render :json => {
        :name => format
      }}
      format.text { render :json => {
        :name => format
      }}
      format.html { render :json => {
        :name => format
      }}
    end
  end
end
