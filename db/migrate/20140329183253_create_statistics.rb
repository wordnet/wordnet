class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.string :name
      t.string :x
      t.string :y
      t.decimal :value

      t.timestamps
    end
    add_index :statistics, :name
    add_index :statistics, :x
    add_index :statistics, :y
  end
end
