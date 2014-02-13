class DropLexemes < ActiveRecord::Migration
  def change
    drop_table :lexemes
    remove_column :senses, :lexeme_id
  end
end
