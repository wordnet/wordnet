class AddPositionToSenses < ActiveRecord::Migration
  def change
    add_column :senses, :position, :integer
  end
end
