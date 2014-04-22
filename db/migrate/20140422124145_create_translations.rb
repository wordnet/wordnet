class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.string :locale
      t.string :key
      t.text   :value
    end
  end
end
