class AddPartOfSpeechToSense < ActiveRecord::Migration
  def change
    add_column :senses, :part_of_speech, :string
  end
end
