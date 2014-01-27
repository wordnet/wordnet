require 'csv'

module WordnetPl
  class RelationType < Importer

    def initialize
      @connection = Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
      super
    end

    def metadata
      @relations_metadata ||= begin
        metadata = CSV.foreach(Rails.root.join('db', 'relations.csv'), headers: true).to_a.map(&:to_h)

        metadata = metadata.map do |r|
          r["id"] = (r["id"] == "NULL") ? nil : r["id"].to_i
          r["reverse_id"] = (r["reverse_id"] == "NULL") ? nil : r["reverse_id"].to_i
          r["parent_id"] = (r["parent_id"] == "NULL") ? nil : r["parent_id"].to_i
          r["priority"] = (r["priority"].blank? || r["priority"] == "NULL") ? 10000 : r["priority"].to_i
          r["primary"] = r["primary"].present?
          r.with_indifferent_access
        end

        metadata = metadata.index_by { |e| e["id"] }
      end
    end

    def unique_attributes
      [:external_id]
    end

    def total_count
      @connection[:relationtype].max(:ID)
    end

    def load_entities(limit, offset)
      raw = @connection[:relationtype].
        select(:ID, :PARENT_ID, :REVERSE_ID, :name, :description, :order).to_a

      raw.map do |relation|
        {
          id: relation[:ID],
          name: relation[:name],
          parent_id: relation[:PARENT_ID],
          reverse_id: relation[:REVERSE_ID],
          description: relation[:description],
          priority: relation[:PARENT_ID].nil? ? relation[:order] * 100 : relation[:order]
        }
      end
    end

    def process_entities!(relations)
      by_id = metadata # Original data is invalid...
      relations = by_id.values

      relations.each do |r|
        if r[:parent_id].present?
          if r[:name].present?
            r[:name] = "#{by_id[r[:parent_id]][:name]} (#{r[:name]})"
          else
            r[:name] = by_id[r[:parent_id]][:name]
          end

          r[:priority] += by_id[r[:parent_id]][:priority]
        end
      end

      one_ways = relations.select { |r| r[:reverse_id].blank? }
      two_ways = relations.select { |r| r[:reverse_id].present? }
      two_ways.sort_by! { |t| t[:primary] ? 0 : 1 }

      reverses = {}

      two_ways.each do |relation|
        unless reverses[relation[:reverse_id]] || reverses[relation[:id]]
          relation[:reverse_name] = by_id[relation[:reverse_id]][:name]
          reverses[relation[:id]] = relation
        end
      end

      all_relations = one_ways + reverses.map { |k, v| v }

      all_relations = all_relations.map do |r|
        r.extract!(:id, :name, :parent_id, :name, :description, :reverse_name, :priority)
      end

      persist_entities!("relation_types", all_relations, [:id])
    end
  end
end
