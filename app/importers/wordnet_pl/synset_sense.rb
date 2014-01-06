module WordnetPl
  class SynsetSense < Importer
    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def table_name
      "synset_senses"
    end

    def uuid_mappings
      {
        :synset_id => { table: :synsets, attribute: :external_id },
        :sense_id => { table: :senses, attribute: :external_id }
      }
    end

    def unique_attributes
      [:synset_id, :sense_id]
    end

    def total_count
      @connection[:unitandsynset].max(:LEX_ID)
    end

    def load_entities(limit, offset)
      raw = @connection[:unitandsynset].
        select(:LEX_ID, :SYN_ID, :unitindex).
        order(:LEX_ID).
        where('LEX_ID >= ? AND LEX_ID < ?', offset, offset + limit).to_a

      raw.map do |membership|
        {
          sense_id: membership[:LEX_ID],
          synset_id: membership[:SYN_ID],
          sense_index: membership[:unitindex]
        }
      end
    end
  end
end
