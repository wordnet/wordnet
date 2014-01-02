class CreateSenses < ActiveRecord::Migration
  def change
    create_table :senses, id: false do |t|
      t.primary_key :id, :uuid, :default => 'uuid_generate_v1()'
      t.integer :external_id, null: false
      t.integer :domain_id
      t.text :comment
    end

    add_index :senses, :external_id, unique: true
  end
end
