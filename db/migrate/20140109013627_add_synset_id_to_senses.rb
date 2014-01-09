class AddSynsetIdToSenses < ActiveRecord::Migration
  def change
    add_column :senses, :synset_id, :uuid
    add_index :senses, :synset_id
  end
end
