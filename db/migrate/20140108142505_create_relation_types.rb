class CreateRelationTypes < ActiveRecord::Migration
  def change
    create_table :relation_types do |t|
      t.integer :parent_id
      t.string :name
      t.string :reverse_name
      t.text :description
    end
  end
end
