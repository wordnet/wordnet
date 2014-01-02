class CreateLexemes < ActiveRecord::Migration
  def change
    create_table :lexemes, id: false do |t|
      t.primary_key :id, :uuid, :default => 'uuid_generate_v1()'
      t.string :lemma, null: false
    end

    add_index :lexemes, :lemma, unique: true
  end
end
