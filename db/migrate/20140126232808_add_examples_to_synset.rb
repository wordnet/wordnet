class AddExamplesToSynset < ActiveRecord::Migration
  def change
    add_column :synsets, :examples, :string, array: true, default: []
  end
end
