class AddExamplesToSynset < ActiveRecord::Migration
  def change
    add_column :synsets, :examples, :string, array: true, limit: 1023, default: []
  end
end
