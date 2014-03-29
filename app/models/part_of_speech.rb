require 'csv'

class PartOfSpeech
  def self.all
    @all ||= begin
      path = Rails.root.join('db', 'part_of_speech.csv')
      metadata = CSV.foreach(path, headers: true).to_a.map(&:to_h)
      metadata.map do |r|
        r["id"] = r["id"].to_i
        Hashie::Mash[r]
      end
    end
  end

  def self.all_by_id
    @all_by_id = all.index_by(&:id)
  end

  def self.find(id)
    all_by_id.fetch(id.to_i)
  end
end
