class DropSynsetSenses < ActiveRecord::Migration
  def change
    drop_table :synset_senses
  end
end
