class AddIndexToSenseIndex < ActiveRecord::Migration
  def change
    add_index :senses, :sense_index
  end
end
