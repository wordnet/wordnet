module WordnetPl
  class Synset < Importer

    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def unique_attributes
      [:external_id]
    end

    def total_count
      @connection[:synset].max(:ID)
    end

    def load_entities(limit, offset)
      raw = @connection[:synset].select(:ID, :comment, :definition).order(:ID).
        where('ID >= ? AND ID < ?', offset, offset + limit).to_a

      raw.map do |synset|
        {
          external_id: synset[:ID],
          comment: process_comment(synset[:comment]),
          definition: process_definition(synset[:definition])
        }
      end
    end

    def table_name
      "synsets"
    end

    private

    def process_comment(comment)
      return nil if comment == "brak danych"
      return nil if comment.include?("{")
      return nil if comment.include?("#")
      return nil if comment.include?("WSD")
      return nil if comment.size < 3
      return nil if comment == "AOds"
      return nil if comment.match(/[a-z]/)
      return nil if comment.blank?
      comment
    end

    def process_definition(definition)
      return nil if definition == "brak danych"
      return nil if definition.include?("{")
      return nil if definition.include?("##")
      return nil if definition.size < 3
      return nil if definition.blank?
      definition.split(";").first.strip
    end
  end
end
