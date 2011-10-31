# -*- coding: utf-8 -*-
module EmailHelper
  def organization_url organization
    organization_path(organization, :only_path => false)
  end

  def project_url project
    project_path(project, :only_path => false)
  end

  def page_url page
    page_path(page, :only_path => false)
  end

  def user_url user
    user_path(user, :only_path => false)
  end
end