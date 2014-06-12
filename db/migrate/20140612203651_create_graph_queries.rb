class CreateGraphQueries < ActiveRecord::Migration
  def change
    create_table :graph_queries, id: false do |t|
      t.primary_key :id, :uuid, :default => 'uuid_generate_v1()'

      t.text :params
    end
  end
end
