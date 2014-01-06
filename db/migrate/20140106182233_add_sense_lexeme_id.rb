class AddSenseLexemeId < ActiveRecord::Migration
  def change
    add_column :senses, :lexeme_id, :uuid
    add_index :senses, :lexeme_id
  end
end
