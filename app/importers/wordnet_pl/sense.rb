require 'csv'

module WordnetPl
  class Sense < Importer

    def initialize
      @connection = Sequel.connect(Figaro.env.source_url, :max_connections => 10)
      super
    end

    def total_count
      @connection[:lexicalunit].max(:ID)
    end

    def process_entities!(senses)
      senses = fill_indexes(senses)

      senses = process_uuid_mappings(
        senses,
        :synset_id => { table: :synsets, attribute: :external_id }
      )

      persist_entities!("senses", senses, [:external_id])
    end

    def fill_indexes(senses)
      rows = @connection[:unitandsynset].
        select(:LEX_ID, :SYN_ID).
        where(:LEX_ID => senses.map { |s| s[:external_id] }).
        to_a

      synset_mapping = Hash[rows.map { |row| [row[:LEX_ID], row[:SYN_ID]] } ]

      senses.each { |s|
        s[:synset_id] = synset_mapping[s[:external_id]]
      }

      senses
    end

    def load_entities(limit, offset)
      raw = @connection[:lexicalunit].
        select(:ID, :comment, :domain, :lemma, :project, :variant, :pos).
        order(:ID).
        where('ID >= ? AND ID < ?', offset, offset + limit).to_a

      raw.map do |lemma|
        {
          external_id: lemma[:ID],
          domain_id: lemma[:domain],
          lemma: lemma[:lemma],
          comment: process_comment(lemma[:comment]),
          examples: extract_examples(lemma[:comment]),
          language: lemma[:project] > 0 ? 'pl_PL' : 'en_GB',
          sense_index: lemma[:variant],
          part_of_speech: convert_pos(lemma[:pos])
        }
      end
    end

    private

    def convert_pos(pos_id)
      PartOfSpeech.find(pos_id).uuid
    end

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

    def extract_examples(comment)
      comment.scan(/\[##W: ([^\]]*)\]/).flatten.map! { |d| d[0..1023] }
    end

  end
end
