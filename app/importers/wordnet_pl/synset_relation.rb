module WordnetPl
  class SynsetRelation < Importer
    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def uuid_mappings
      {
        :parent_id => { table: :synsets, attribute: :external_id },
        :child_id => { table: :synsets, attribute: :external_id }
      }
    end

    def unique_attributes
      [:parent_id, :child_id, :relation_id]
    end

    def wordnet_count
      @connection[:synsetrelation].max(:PARENT_ID)
    end

    def wordnet_load(limit, offset)
      raw = @connection[:synsetrelation].
        select(:PARENT_ID, :CHILD_ID, :REL_ID).
        where('PARENT_ID >= ? AND PARENT_ID < ?', offset, offset + limit).
        to_a

      raw.map do |relation|
        {
          relation_id: relation[:REL_ID],
          parent_id: relation[:PARENT_ID],
          child_id: relation[:CHILD_ID]
        }
      end
    end

    def table_name
      "synset_relations"
    end
  end
end

