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
        select(:ID, :comment, :domain, :lemma, :pos).
        order(:ID).
        where('ID >= ? AND ID < ?', offset, offset + limit).to_a

      raw.map do |lexeme|
        {
          external_id: lexeme[:ID],
          domain_id: lexeme[:domain],
          lexeme_id: lexeme[:lemma],
          position: lexeme[:pos],
          comment: lexeme[:comment] == "brak danych" ? nil : lexeme[:comment].presence
        }
      end
    end

  end
end
