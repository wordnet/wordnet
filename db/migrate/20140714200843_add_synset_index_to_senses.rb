class AddSynsetIndexToSenses < ActiveRecord::Migration
  def change
    add_column :senses, :synset_index, :integer
    add_index :senses, :synset_index
  end
end
