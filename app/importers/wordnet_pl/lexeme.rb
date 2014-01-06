module WordnetPl
  class Lexeme < Importer

    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def unique_attributes
      [:lemma]
    end

    def wordnet_count
      @connection[:lexicalunit].max(:ID)
    end

    def table_name
      "lexemes"
    end

    def wordnet_load(limit, offset)
      raw = @connection[:lexicalunit].select(:lemma).order(:ID).
        where('ID >= ? AND ID < ?', offset, offset + limit).to_a

      lemmas = raw.map { |r| r[:lemma] }.uniq

      lemmas.map do |lemma|
        { lemma: lemma }
      end
    end

  end
end
