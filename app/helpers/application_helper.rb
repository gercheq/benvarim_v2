# -*- coding: utf-8 -*-
module ApplicationHelper
  @bufferedOutput = ""
  def print_if_selected_tab cont, act
    return "" unless (cont.nil? || cont.to_s == controller.controller_name)
    return "" unless (act.nil? || act.to_s == controller.action_name)
    "selected"
  end

  def requires_bootstrap?
    #  ["home"].include? controller.controller_name
    return false
  end

  def is_in_homepage
    controller.controller_name == "home" &&
      (controller.action_name == "nedir" || controller.action_name == "index")
  end

  def body_id
    id = "i-#{controller.controller_name}-#{controller.action_name}"
    if(controller.controller_name == "pages" && controller.action_name == "show" && @page != nil)
      id += "-#{@page.id}"
    end
    id
  end

  def body_class
    classes = "c-#{controller.controller_name} c-#{controller.action_name}"
    if(controller.controller_name == "pages" && controller.action_name == "show" && @page != nil)
      classes += " c-org-#{@page.organization.id}"
    end
    classes
  end

  def human_readable_datetime datetime
    if datetime.nil?
      return '-'
    end
    l datetime, :format => :long
  end

  def render_at_the_end data
    @bufferedOutput ||= ""
    @bufferedOutput += data
  end

  def get_buffered_output
    @bufferedOutput
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

  def fb_og_images
    images = Array.new
    if @page && @page.logo.file?
      if @page.logo.file?
        images.push url_for @page.logo.url(:medium)
      end

      if @page.user && @page.user.photo.file?
        images.push url_for @page.user.photo.url(:medium)
      end

      if @page.project && @page.project.logo.file?
        images.push url_for @page.project.logo.url(:medium)
      end
      if @page.organization && @page.organization.logo.file?
        images.push url_for @page.organization.logo.url(:medium)
      end
    elsif @project
      if @project.logo.file?
        images.push url_for @project.logo.url(:medium)
      end
      if @project.organization.logo.file?
        images.push url_for @project.organization.logo.url(:medium)
      end
    elsif @organization
      if @organization.logo.file?
        images.push url_for @organization.logo.url(:medium)
      end
    elsif @user
      if @user.photo.file?
        images.push url_for @user.photo.url(:medium)
      end
    end
    images.push "#{url_for root_path :only_path => false}stylesheets/images/logo.gif"
    images.uniq
  end

  def tags_title
    if @page && @page.project
      return "#{@page.project.name} | BenVarim.com"
    end
    if @project
      return "#{@project.name} | BenVarim.com"
    end
    if @organization
      return "#{@organization.name} | BenVarim.com"
    end
      "BenVarım Kolay Bağış Platformu | BenVarim.com"
  end

  def tags_description
    if @page && @page.organization && @page.project
      return "#{@page.organization.name} BenVarim platformu'ndan bağış toplayarak #{@page.project.name} güçlendiriyor
      ve projelerin tanıtımını sağlıyor. Siz de gönüllü ve hayırsever olarak yapacağınız bağışlarınızla projeleri güçlendirin."
    end
    if @project && @project.organization
      return "#{@project.organization.name} BenVarim platformu'ndan bağış toplayarak #{@project.name} güçlendiriyor
      ve projelerin tanıtımını sağlıyor. Siz de gönüllü ve hayırsever olarak yapacağınız bağışlarınızla projeleri güçlendirin."
    end
    if @organization
      return "#{@organization.name} BenVarim platformu ile bağış toplayarak projelerini güçlendirmekte ve tanıtımını sağlamaktadır.
      Bağış yaparak desteklediğiniz kurumu güçlendirebilirsiniz."
    end
      "BenVarım, vakıf ve dernek'lerin sosyal sorumluluk projeleri için bağış ve tanıtım platformudur. BenVarım platformu ile Türkiye'deki
      vakıf ve dernekler ile gönüllüleri internet üzerinde bağış sayfası yaratarak projelere kaynak yaratabilir ve kurumlarını güçlendirebilirler."
  end

  def tags_keywords
    if @page && @page.project && @page.organization
      return "#{@page.organization.name}, #{@page.project.name}, vakıf, vakif, dernek, kurum, proje, hayır projesi, projeye destek, yardım, yardim,
      destek, STK, sivil toplum, sosyal proje, aktivite, bağış, bagis, kolay bağış, platform, benvarim, ben varim, benvarım, ben varım, benvarim.com"
    end
    if @project && @project.organization
      return "#{@project.organization.name}, #{@project.name}, vakıf, vakif, dernek, kurum, proje, hayır projesi, projeye destek, yardım, yardim,
      destek, STK, sivil toplum, sosyal proje, aktivite, bağış, bagis, kolay bağış, platform, benvarim, ben varim, benvarım, ben varım, benvarim.com"
    end
    if @organization
      projectnames = ", "

      @organization.projects.each do |project|
        projectnames += project.name + ", "
      end

      return "#{@organization.name}" + projectnames + "vakıf, vakif, dernek, kurum, yardım, yardim, destek, STK, sivil toplum, sosyal proje, aktivite,
      bağış, bagis, kolay bağış, platform, benvarim, ben varim, benvarım, ben varım, benvarim.com"
    end
      "vakıf, vakif, dernek, kurum, yardım, yardımsever, bağışçı, yardim, STK, sivil toplum, sosyal proje, aktivite, bağış, bagis, gönüllü, maraton,
      fundraising, koşu, kolay bağış, platform, benvarim, ben varim, benvarım, ben varım, benvarim.com"
  end
end
