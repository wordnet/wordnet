class AddExtraFieldsToSynsets < ActiveRecord::Migration
  def change
    add_column :synsets, :language, :string
    add_column :synsets, :lemma, :string
    add_column :synsets, :part_of_speech, :string

    add_index :synsets, :language
    add_index :synsets, :part_of_speech
  end
end
