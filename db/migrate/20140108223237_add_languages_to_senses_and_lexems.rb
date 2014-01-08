class AddLanguagesToSensesAndLexems < ActiveRecord::Migration
  def change
    add_column :senses, :language, :string
    add_column :lexemes, :language, :string

    add_index :senses, :language
    add_index :lexemes, :language
  end
end
