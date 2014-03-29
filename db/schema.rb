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

ActiveRecord::Schema.define(version: 20140329183253) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "relation_types", force: true do |t|
    t.integer "parent_id"
    t.string  "name"
    t.string  "reverse_name"
    t.text    "description"
    t.integer "priority"
  end

  create_table "sense_relations", force: true do |t|
    t.uuid    "parent_id",   null: false
    t.uuid    "child_id",    null: false
    t.integer "relation_id", null: false
  end

  add_index "sense_relations", ["parent_id", "child_id", "relation_id"], name: "sense_relations_idx", unique: true, using: :btree

  create_table "senses", id: :uuid, default: "uuid_generate_v1()", force: true do |t|
    t.integer "external_id",    null: false
    t.integer "domain_id"
    t.text    "comment"
    t.integer "sense_index"
    t.string  "language"
    t.string  "lemma"
    t.uuid    "synset_id"
    t.string  "part_of_speech"
  end

  add_index "senses", ["external_id"], name: "index_senses_on_external_id", unique: true, using: :btree
  add_index "senses", ["language"], name: "index_senses_on_language", using: :btree
  add_index "senses", ["lemma"], name: "index_senses_on_lemma", using: :btree
  add_index "senses", ["synset_id"], name: "index_senses_on_synset_id", using: :btree

  create_table "statistics", force: true do |t|
    t.string   "name"
    t.string   "x"
    t.string   "y"
    t.decimal  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statistics", ["name"], name: "index_statistics_on_name", using: :btree
  add_index "statistics", ["x"], name: "index_statistics_on_x", using: :btree
  add_index "statistics", ["y"], name: "index_statistics_on_y", using: :btree

  create_table "synset_relations", force: true do |t|
    t.uuid    "parent_id",   null: false
    t.uuid    "child_id",    null: false
    t.integer "relation_id", null: false
  end

  add_index "synset_relations", ["parent_id", "child_id", "relation_id"], name: "synset_relations_idx", unique: true, using: :btree

  create_table "synsets", id: :uuid, default: "uuid_generate_v1()", force: true do |t|
    t.integer "external_id",              null: false
    t.text    "comment"
    t.text    "definition"
    t.string  "examples",    default: [],              array: true
  end

  add_index "synsets", ["external_id"], name: "index_synsets_on_external_id", unique: true, using: :btree

end
