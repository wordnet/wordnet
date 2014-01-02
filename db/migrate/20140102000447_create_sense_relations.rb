class CreateSenseRelations < ActiveRecord::Migration
  def change
    create_table :sense_relations do |t|
      t.uuid :parent_id
      t.uuid :child_id
      t.integer :relation_id
    end
  end
end
