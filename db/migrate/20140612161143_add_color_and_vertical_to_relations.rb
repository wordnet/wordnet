class AddColorAndVerticalToRelations < ActiveRecord::Migration
  def change
    add_column :relation_types, :color, :string
    add_column :relation_types, :vertical, :boolean
  end
end
