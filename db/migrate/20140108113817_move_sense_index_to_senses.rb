class MoveSenseIndexToSenses < ActiveRecord::Migration
  def change
    remove_column :synset_senses, :sense_index, :integer
    add_column :senses, :sense_index, :integer
  end
end
