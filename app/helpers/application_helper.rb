module ApplicationHelper
  def print_if_selected_tab cont, act
    return "" unless (cont.nil? || cont.to_s == controller.controller_name)
    return "" unless (act.nil? || act.to_s == controller.action_name)
    "selected"
  end
end
