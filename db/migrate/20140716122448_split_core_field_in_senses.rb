class SplitCoreFieldInSenses < ActiveRecord::Migration
  def change
    remove_column :senses, :core

    add_column :senses, :sense_core, :boolean,
      null: false, default: false

    add_column :senses, :synset_core, :boolean,
      null: false, default: false

    add_index :senses, :sense_core
    add_index :senses, :synset_core
  end
end
