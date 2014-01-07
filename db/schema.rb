# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140106213106) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "lexemes", id: :uuid, default: "uuid_generate_v1()", force: true do |t|
    t.string "lemma", null: false
  end

  add_index "lexemes", ["lemma"], name: "index_lexemes_on_lemma", unique: true, using: :btree

  create_table "sense_relations", force: true do |t|
    t.uuid    "parent_id",   null: false
    t.uuid    "child_id",    null: false
    t.integer "relation_id", null: false
  end

  add_index "sense_relations", ["parent_id", "child_id", "relation_id"], name: "sense_relations_idx", unique: true, using: :btree

  create_table "senses", id: :uuid, default: "uuid_generate_v1()", force: true do |t|
    t.integer "external_id", null: false
    t.integer "domain_id"
    t.text    "comment"
    t.uuid    "lexeme_id"
  end

  add_index "senses", ["external_id"], name: "index_senses_on_external_id", unique: true, using: :btree
  add_index "senses", ["lexeme_id"], name: "index_senses_on_lexeme_id", using: :btree

  create_table "synset_relations", force: true do |t|
    t.uuid    "parent_id",   null: false
    t.uuid    "child_id",    null: false
    t.integer "relation_id", null: false
  end

  add_index "synset_relations", ["parent_id", "child_id", "relation_id"], name: "synset_relations_idx", unique: true, using: :btree

  create_table "synset_senses", force: true do |t|
    t.uuid    "synset_id",   null: false
    t.uuid    "sense_id",    null: false
    t.integer "sense_index"
  end

  add_index "synset_senses", ["synset_id", "sense_id"], name: "index_synset_senses_on_synset_id_and_sense_id", unique: true, using: :btree

  create_table "synsets", id: :uuid, default: "uuid_generate_v1()", force: true do |t|
    t.integer "external_id", null: false
    t.text    "comment"
    t.text    "definition"
  end

  add_index "synsets", ["external_id"], name: "index_synsets_on_external_id", unique: true, using: :btree

end
