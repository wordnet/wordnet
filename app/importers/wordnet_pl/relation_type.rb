module WordnetPl
  class RelationType < Importer

    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def unique_attributes
      [:external_id]
    end

    def total_count
      @connection[:relationtype].max(:ID)
    end

    def load_entities(limit, offset)
      raw = @connection[:relationtype].
        select(:ID, :PARENT_ID, :REVERSE_ID, :name, :description).to_a

      raw.map do |relation|
        {
          id: relation[:ID],
          name: relation[:name],
          parent_id: relation[:PARENT_ID],
          reverse_id: relation[:REVERSE_ID],
          description: relation[:description]
        }
      end
    end

    def process_entities!(relations)
      by_id = Hash[relations.map { |r| [r[:id], r] }]

      one_ways = relations.select { |r| r[:reverse_id].blank? }
      two_ways = relations.select { |r| r[:reverse_id].present? }

      reverses = {}

      two_ways.each do |relation|
        unless reverses.has_key?(relation[:id])
          relation[:reverse_name] = by_id[relation[:reverse_id]][:name]
          reverses[relation[:id]] = relation
        end
      end

      all_relations = one_ways + reverses.map { |k, v| v }

      all_relations = all_relations.map do |r|
        r.extract!(:id, :name, :parent_id, :name, :description, :reverse_name)
      end

      persist_entities!("relation_types", all_relations, [:id])
    end
  end
end
