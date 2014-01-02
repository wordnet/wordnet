class CreateSynsetSenses < ActiveRecord::Migration
  def change
    create_table :synset_senses do |t|
      t.uuid :synset_id, null: false
      t.uuid :sense_id, null: false
    end

    add_index :synset_senses, [:synset_id, :sense_id], unique: true
  end
end
