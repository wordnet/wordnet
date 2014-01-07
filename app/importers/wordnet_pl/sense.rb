module WordnetPl
  class Sense < Importer

    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def total_count
      @connection[:lexicalunit].max(:ID)
    end

    def process_entities!(entities)
      lexemes = entities.map { |e| { lemma: e[:lexeme_id] } }

      persist_entities!("lexemes", lexemes, [:lemma])

      entities = process_uuid_mappings(entities, :lexeme_id => { table: :lexemes, attribute: :lemma })

      persist_entities!("senses", entities, [:external_id])
    end

    def load_entities(limit, offset)
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
