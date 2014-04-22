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
    @translations ||=
      begin
        I18n.backend.send(:init_translations)
        translations = I18n.backend.send(:translations)
        Hash[translations.map do |lang, t| 
          t.merge!(
            Hash[Translation.where(:locale => lang.to_s).map do |t2|
              [t2[:key], t2[:value]]
            end]
          )
        end]

        translations
      end
  end

  helper_method :translations
end
