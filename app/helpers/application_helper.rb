# -*- coding: utf-8 -*-
module ApplicationHelper
  def print_if_selected_tab cont, act
    return "" unless (cont.nil? || cont.to_s == controller.controller_name)
    return "" unless (act.nil? || act.to_s == controller.action_name)
    "selected"
  end

  def human_readable_datetime datetime
    if datetime.nil?
      return '-'
    end
    l datetime, :format => :long
  end

  def add_page_specific_script script_name
    unless @page_spicific_scripts
      @page_spicific_scripts = Array.new
    end
    @page_spicific_scripts.push script_name
  end
  def get_page_specific_scripts
    return @page_spicific_scripts || Array.new
  end

  def fb_og_title
    if @page
      return @page.title
    end
    if @project
      return @project.name
    end
    if @organization
      return @organization.name
    end
    "Benvarim.com"
  end

  def fb_og_description
    if @page
      return @page.description
    end
    if @project
      return @project.description
    end
    if @organization
      return @organization.description
    end
    "BenVarım, sosyal sorumluluk projeleri için bağış ve tanıtım platformudur.
    Gönüllüsü olduğunuz vakıf veya derneğin, bağış kampanyasına katılarak kendinize bir web sayfası yaratabilirsiniz.
    BenVarım ile, sosyal ağınızda bulunan arkadaş, akraba ve diğer gönüllülere kolayca ulaşacak ve daha fazla bağış
    toplanmasına aracı olacaksınız."
  end

  def fb_og_image
    if @page
      if @page.logo.file?
        return (url_for @page.logo.url(:medium))
      end
      if @page.project && @page.project.logo.file?
        return (url_for @page.project.logo.url(:medium))
      end
      if @page.organization && @page.organization.logo.file?
        return (url_for @page.organization.logo.url(:medium))
      end
    end
    if @project
      if @project.logo.file?
        return (url_for @project.logo.url(:medium))
      end
      if @project.organization.logo.file?
        return (url_for @project.organization.logo.url(:medium))
      end
    end
    if @organization
      if @organization.logo.file?
        return (url_for @organization.logo.url(:medium))
      end
    end
      "#{url_for root_path}stylesheets/images/logo.gif"
  end
end
