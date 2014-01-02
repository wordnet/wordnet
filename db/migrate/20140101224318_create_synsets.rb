class CreateSynsets < ActiveRecord::Migration
  def change
    create_table :synsets, id: false do |t|
      t.primary_key :id, :uuid, :default => 'uuid_generate_v1()'

      t.integer :external_id, null: false
      t.text :comment
      t.text :definition
    end

    add_index :synsets, :external_id, unique: true
  end
end
