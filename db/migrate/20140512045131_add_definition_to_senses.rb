class AddDefinitionToSenses < ActiveRecord::Migration
  def change
    add_column :senses, :definition, :text
  end
end
