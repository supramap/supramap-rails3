# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 12) do

  create_table "jobs", :force => true do |t|
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "completed_at"
    t.string   "name"
    t.string   "status"
    t.string   "job_type"
    t.integer  "job_code"
    t.integer  "color_type"
    t.integer  "color_alignment"
  end

  create_table "jobs_sfiles", :id => false, :force => true do |t|
    t.integer "job_id"
    t.integer "sfile_id"
  end

  create_table "projects", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.string   "name"
  end

  create_table "queries", :force => true do |t|
    t.string   "anc_state"
    t.string   "descs_state"
    t.string   "position"
    t.string   "insdel"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sfiles", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.datetime "created_at"
    t.string   "filetype"
    t.string   "ext"
    t.string   "desc"
  end

  create_table "transformations", :force => true do |t|
    t.integer "treenode_id"
    t.boolean "definite"
    t.string  "ancestral_state"
    t.string  "descendant_state"
    t.integer "position"
    t.string  "type"
    t.string  "cost"
    t.string  "character"
  end

  create_table "treenodes", :force => true do |t|
    t.integer  "job_id"
    t.integer  "parent_id"
    t.string   "strain_name"
    t.integer  "rank"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "isolation_date"
  end

  create_table "users", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "login"
    t.string   "hashed_password"
    t.string   "email"
    t.string   "salt"
    t.boolean  "admin"
    t.boolean  "auth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
