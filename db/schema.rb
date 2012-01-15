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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120111082510) do

  create_table "bvlogs", :force => true do |t|
    t.string   "namespace"
    t.text     "content"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_forms", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.string   "phone"
    t.string   "email"
    t.string   "organization"
    t.string   "organization_role"
    t.text     "other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fb_connects", :force => true do |t|
    t.integer  "user_id"
    t.string   "fb_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "auth"
  end

  add_index "fb_connects", ["user_id"], :name => "index_fb_connects_on_user_id", :unique => true

  create_table "kvdbs", :id => false, :force => true do |t|
    t.string   "key",        :limit => 128
    t.text     "value"
    t.datetime "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "address"
    t.text     "description"
    t.boolean  "approved",          :default => false
    t.boolean  "active",            :default => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.text     "description_html"
    t.string   "website"
    t.float    "collected",         :default => 0.0
    t.string   "email"
    t.string   "phone"
    t.string   "contact_name"
    t.string   "contact_title"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.string   "cached_slug"
  end

  add_index "organizations", ["cached_slug"], :name => "index_organizations_on_cached_slug", :unique => true

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.float    "goal",              :default => 0.0
    t.float    "collected",         :default => 0.0
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "project_id"
    t.boolean  "active",            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description_html"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "cached_slug"
  end

  add_index "pages", ["cached_slug"], :name => "index_pages_on_cached_slug", :unique => true

  create_table "payments", :force => true do |t|
    t.string   "name"
    t.text     "note"
    t.string   "email"
    t.integer  "page_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.integer  "organization_id"
    t.string   "currency",              :default => "TRY"
    t.float    "amount_in_currency"
    t.integer  "predefined_payment_id", :default => 0
    t.boolean  "hide_name",             :default => false
  end

  create_table "paypal_infos", :force => true do |t|
    t.integer  "organization_id"
    t.string   "paypal_user"
    t.string   "paypal_id_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency",        :default => "TRY"
  end

  create_table "predefined_payments", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "description"
    t.boolean  "disabled",    :default => false
    t.boolean  "deleted",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount"
    t.integer  "priority",    :default => 0
    t.integer  "count",       :default => 0
    t.float    "collected",   :default => 0.0
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "description"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.float    "collected",              :default => 0.0
    t.boolean  "active",                 :default => true
    t.string   "cached_slug"
    t.boolean  "accepts_random_payment", :default => true
    t.text     "description_html"
  end

  add_index "projects", ["cached_slug"], :name => "index_projects_on_cached_slug", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tmp_payments", :force => true do |t|
    t.string   "name"
    t.text     "note"
    t.string   "email"
    t.integer  "page_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.integer  "payment_id"
    t.integer  "organization_id"
    t.string   "currency",              :default => "TRY"
    t.float    "amount_in_currency"
    t.integer  "predefined_payment_id", :default => 0
    t.boolean  "hide_name",             :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.date     "birthday"
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "cached_slug"
  end

  add_index "users", ["cached_slug"], :name => "index_users_on_cached_slug", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
