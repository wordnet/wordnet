module WordnetPl
  class Sense < Importer

    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def total_count
      @connection[:lexicalunit].max(:ID)
    end

    def process_entities!(senses)
      lexemes = senses.map { |e| { lemma: e[:lexeme_id] } }

      persist_entities!("lexemes", lexemes, [:lemma])

      senses = process_uuid_mappings(senses, :lexeme_id => { table: :lexemes, attribute: :lemma })
      senses = fill_indexes(senses)

      persist_entities!("senses", senses, [:external_id])
    end

    def fill_indexes(senses)
      rows = @connection[:unitandsynset].
        select(:LEX_ID, :unitindex).
        where(:LEX_ID => senses.map { |s| s[:external_id] }).
        to_a

      index_mapping = Hash[rows.map { |row| [row[:LEX_ID], row[:unitindex]] } ]

      senses.each { |s|
        s[:sense_index] = index_mapping[s[:external_id]].to_i + 1
      }

      senses
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
          comment: process_comment(lemma[:comment])
        }
      end
    end

    private

    def process_comment(comment)
      return nil if comment.blank?
      return nil if comment == "brak danych"
      return nil if comment.include?("{")
      return nil if comment.include?("#")
      return nil if comment.include?("WSD")
      return nil if comment.size < 3
      return nil if comment == "AOds"
      return nil unless comment.match(/[a-z]/)
      comment
    end

  end
end
