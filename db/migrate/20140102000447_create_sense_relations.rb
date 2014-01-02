class CreateSenseRelations < ActiveRecord::Migration
  def change
    create_table :sense_relations do |t|
      t.uuid :parent_id, null: false
      t.uuid :child_id, null: false
      t.integer :relation_id, null: false
    end

    add_index :sense_relations, [:parent_id, :child_id, :relation_id],
      unique: true,
      name: 'sense_relations_idx'
  end
end
