class CreateLexemeSenses < ActiveRecord::Migration
  def change
    create_table :lexeme_senses do |t|
      t.uuid :lexeme_id, null: false
      t.uuid :sense_id, null: false
    end

    add_index :lexeme_senses, [:lexeme_id, :sense_id], unique: true
  end
end
