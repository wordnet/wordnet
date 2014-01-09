class AddLemmaToSense < ActiveRecord::Migration
  def change
    add_column :senses, :lemma, :string
    add_index :senses, :lemma
  end
end
