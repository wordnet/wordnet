class AddSenseIndexToSynsetSenses < ActiveRecord::Migration
  def change
    add_column :synset_senses, :sense_index, :integer
  end
end
