module ApplicationHelper
  include LocalTimeHelper

  def body_class
    body_class = @body_class || "default"
    body_class += " " + controller.controller_name.dasherize
    body_class += " " + controller.action_name.dasherize
    body_class
  end

  def page_title
    page = @title
    if page
      "#{page} | #{site_title}"
    else
      site_title
    end
  end

  def site_title
    "Simple Beer"
  end

end
