class CreateSynsetRelations < ActiveRecord::Migration
  def change
    create_table :synset_relations do |t|
      t.uuid :parent_id, null: false
      t.uuid :child_id, null: false
      t.integer :relation_id, null: false
    end

    add_index :synset_relations, [:parent_id, :child_id, :relation_id],
      unique: true,
      name: 'synset_relations_idx'
  end
end
