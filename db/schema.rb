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

ActiveRecord::Schema.define(version: 20160808070319) do

  create_table "customers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "code",       limit: 4
  end

  create_table "inspect_data", force: :cascade do |t|
    t.float    "num_data",      limit: 24
    t.string   "str_data",      limit: 255
    t.integer  "production_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "inspection_id", limit: 4
    t.integer  "num",           limit: 4
  end

  add_index "inspect_data", ["inspection_id"], name: "index_inspect_data_on_inspection_id", using: :btree
  add_index "inspect_data", ["production_id"], name: "index_inspect_data_on_production_id", using: :btree

  create_table "inspect_logs", force: :cascade do |t|
    t.string   "num",         limit: 255
    t.string   "kind",        limit: 255
    t.string   "synopsis",    limit: 255
    t.string   "standard",    limit: 255
    t.string   "min",         limit: 255
    t.string   "max",         limit: 255
    t.string   "tool",        limit: 255
    t.string   "unit",        limit: 255
    t.datetime "change_date"
    t.string   "remark",      limit: 255
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "inspect_logs", ["product_id"], name: "index_inspect_logs_on_product_id", using: :btree

  create_table "inspections", force: :cascade do |t|
    t.integer  "num",        limit: 4
    t.string   "synopsis",   limit: 255
    t.string   "standard",   limit: 255
    t.string   "min",        limit: 255
    t.string   "max",        limit: 255
    t.string   "tool",       limit: 255
    t.string   "unit",       limit: 255
    t.integer  "product_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "remark",     limit: 255
  end

  add_index "inspections", ["product_id"], name: "index_inspections_on_product_id", using: :btree

  create_table "product_logs", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "num",         limit: 255
    t.string   "name",        limit: 255
    t.string   "material",    limit: 255
    t.string   "heat",        limit: 255
    t.string   "surface",     limit: 255
    t.datetime "change_date"
    t.string   "remark",      limit: 255
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "product_logs", ["product_id"], name: "index_product_logs_on_product_id", using: :btree

  create_table "productions", force: :cascade do |t|
    t.string   "lot",          limit: 255
    t.integer  "pcs",          limit: 4
    t.integer  "product_id",   limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.datetime "inspect_date"
  end

  add_index "productions", ["product_id"], name: "index_productions_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "num",         limit: 255
    t.string   "name",        limit: 255
    t.string   "material",    limit: 255
    t.string   "surface",     limit: 255
    t.string   "heat",        limit: 255
    t.integer  "customer_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "code",        limit: 255
  end

  add_index "products", ["customer_id"], name: "index_products_on_customer_id", using: :btree

  create_table "recent_customers", force: :cascade do |t|
    t.integer  "customer_id", limit: 4
    t.datetime "access_date"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "recent_customers", ["customer_id"], name: "index_recent_customers_on_customer_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "password_digest", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_foreign_key "inspect_data", "productions"
  add_foreign_key "inspect_logs", "products"
  add_foreign_key "inspections", "products"
  add_foreign_key "product_logs", "products"
  add_foreign_key "productions", "products"
  add_foreign_key "products", "customers"
end
