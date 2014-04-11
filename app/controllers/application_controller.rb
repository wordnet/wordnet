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
end
