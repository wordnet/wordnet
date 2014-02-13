module WordnetPl
  class SenseRelation < Importer
    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      @relation_ids = ::RelationType.all.to_a.map(&:id)
      super
    end

    def uuid_mappings
      {
        :parent_id => { table: :senses, attribute: :external_id },
        :child_id => { table: :senses, attribute: :external_id }
      }
    end

    def unique_attributes
      [:parent_id, :child_id, :relation_id]
    end

    def total_count
      @connection[:lexicalrelation].max(:PARENT_ID)
    end

    def load_entities(limit, offset)
      raw = @connection[:lexicalrelation].
        select(:PARENT_ID, :CHILD_ID, :REL_ID).
        order(:PARENT_ID).
        where('PARENT_ID >= ? AND PARENT_ID < ?', offset, offset + limit).to_a

      raw.map do |relation|
        if @relation_ids.include?(relation[:REL_ID])
          {
            relation_id: relation[:REL_ID],
            # PlWordnet gets it backward
            parent_id: relation[:CHILD_ID], 
            child_id: relation[:PARENT_ID]
          }
        end
      end.compact
    end

    def table_name
      "sense_relations"
    end
  end
end
