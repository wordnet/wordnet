class DropLexemeSenses < ActiveRecord::Migration
  def change
    drop_table :lexeme_senses
  end
end
