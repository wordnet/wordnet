require 'csv'

module WordnetPl
  class RelationType < Importer

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

        metadata
      end
    end

    def unique_attributes
      [:id]
    end

    def total_count
      metadata.size
    end

    def load_entities(limit, offset)
      metadata.map do |item|
        item[:priority] = item[:parent_id].present? ? item[:priority] * 100 : item[:priority]
        item
      end
    end

    def process_entities!(relations)
      by_id = relations.index_by { |e| e[:id] }

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
