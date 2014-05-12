class Translation < ActiveRecord::Base

  def self.export
    Domain.all.each do |domain|
      Rails.logger.info "Exporting domain ##{domain.id}..."

      ['pl', 'en'].each do |locale|
        t = Translation.find_or_initialize_by(locale: locale, key: "domain_#{domain.id}") do |t|
          t.value = domain[locale]
        end

        t.save!
      end
    end
  
    true
  end

end
