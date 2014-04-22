class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout :determine_layout

  def determine_layout
    if request.path.start_with?('/template')
      false
    else
      "application"
    end
  end

  def translations
    I18n.backend.send(:init_translations)
    I18n.backend.send(:translations)
  end

  helper_method :translations
end
