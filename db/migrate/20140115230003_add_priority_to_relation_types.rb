class AddPriorityToRelationTypes < ActiveRecord::Migration
  def change
    add_column :relation_types, :priority, :integer
  end
end
