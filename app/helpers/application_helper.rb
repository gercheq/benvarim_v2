module ApplicationHelper
  def print_if_selected_tab cont, act
    return "" unless (cont.nil? || cont.to_s == controller.controller_name)
    return "" unless (act.nil? || act.to_s == controller.action_name)
    "selected"
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
end
