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
        select(:LEX_ID, :SYN_ID, :unitindex).
        where(:LEX_ID => senses.map { |s| s[:external_id] }).
        to_a

      synset_mapping = Hash[rows.map { |row| [row[:LEX_ID], row[:SYN_ID]] } ]
      index_mapping = Hash[rows.map { |row| [row[:LEX_ID], row[:unitindex]] } ]

      senses.each { |s|
        s[:synset_id] = synset_mapping[s[:external_id]]
        s[:synset_index] = index_mapping[s[:external_id]]
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
          comment: extract_short_definition(lemma[:comment]),
          examples: extract_examples(lemma[:comment]),
          definition: extract_definition(lemma[:comment]),
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
      return nil if comment.include?("brak danych")
      return nil if comment.include?("##")
      return nil if comment[0..1] == "NP"
      comment.match(/^([^#<]+)/).to_s.presence
    end

    def extract_examples(comment)
      comment.
        scan(/\[##[^:]+: ([^\]]*)\]/).
        flatten.
        map { |d| d.strip[0..1023] }.
        reject(&:empty?)
    end

    def extract_short_definition(comment)
      definition = comment.scan(/##D: ([^\.]+)\./).flatten.first
      definition && definition.size < 128 ? definition : nil
    end

    def extract_definition(comment)
      definition = comment.scan(/##D: ([^\.]+)\./).flatten.first
      definition && definition.size >= 128 ? definition : nil
    end
  end
end
