module WordnetPl
  class Sense < Importer

    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def table_name
      "senses"
    end

    def unique_attributes
      [:external_id]
    end

    def wordnet_count
      @connection[:lexicalunit].max(:ID)
    end

    def uuid_mappings
      {
        :lexeme_id => { table: :lexemes, attribute: :lemma },
      }
    end

    def wordnet_load(limit, offset)
      raw = @connection[:lexicalunit].
        select(:ID, :comment, :domain, :lemma).
        order(:ID).
        where('ID >= ? AND ID < ?', offset, offset + limit).to_a

      raw.map do |lemma|
        {
          external_id: lemma[:ID],
          domain_id: lemma[:domain],
          lexeme_id: lemma[:lemma],
          comment: lemma[:comment] == "brak danych" ? nil : lemma[:comment].presence
        }
      end
    end

  end
end
