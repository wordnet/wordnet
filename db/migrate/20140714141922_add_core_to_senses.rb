class AddCoreToSenses < ActiveRecord::Migration
  def change
    add_column :senses, :core, :boolean, default: false
    add_index :senses, :core
  end
end
