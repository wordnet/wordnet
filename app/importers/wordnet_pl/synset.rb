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

    def load_batch(limit, offset)
      raw = @connection[:synset].select(:ID, :comment, :definition).order(:ID).
        where('ID >= ? AND ID < ?', offset, offset + limit).to_a

      raw.map do |synset|
        {
          external_id: synset[:ID],
          comment: synset[:comment],
          definition: synset[:definition] == "brak danych" ? nil : synset[:definition].presence
        }
      end
    end

    def table_name
      "synsets"
    end
  end
end
