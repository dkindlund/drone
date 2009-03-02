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

ActiveRecord::Schema.define(:version => 20090228170041) do

  create_table "applications", :force => true do |t|
    t.string "manufacturer", :null => false
    t.string "version",      :null => false
    t.string "short_name",   :null => false
  end

  add_index "applications", ["manufacturer", "version", "short_name"], :name => "index_applications_on_manufacturer", :unique => true

  create_table "client_statuses", :force => true do |t|
    t.string "status",      :null => false
    t.text   "description", :null => false
  end

  add_index "client_statuses", ["status"], :name => "index_client_statuses_on_status", :unique => true

  create_table "clients", :force => true do |t|
    t.string   "quick_clone_name", :null => false
    t.string   "snapshot_name",    :null => false
    t.datetime "suspended_at"
    t.integer  "host_id",          :null => false
    t.integer  "client_status_id", :null => false
    t.integer  "os_id"
    t.integer  "application_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "clients", ["application_id"], :name => "index_clients_on_application_id"
  add_index "clients", ["client_status_id"], :name => "index_clients_on_client_status_id"
  add_index "clients", ["created_at"], :name => "index_clients_on_created_at"
  add_index "clients", ["host_id"], :name => "index_clients_on_host_id"
  add_index "clients", ["os_id"], :name => "index_clients_on_os_id"
  add_index "clients", ["quick_clone_name", "snapshot_name"], :name => "index_clients_on_quick_clone_name", :unique => true
  add_index "clients", ["suspended_at"], :name => "index_clients_on_suspended_at"
  add_index "clients", ["updated_at"], :name => "index_clients_on_updated_at"

  create_table "configurations", :force => true do |t|
    t.string "name",          :null => false
    t.string "value",         :null => false
    t.string "namespace",     :null => false
    t.text   "description"
    t.string "default_value"
  end

  add_index "configurations", ["name"], :name => "index_configurations_on_name"
  add_index "configurations", ["namespace"], :name => "index_configurations_on_namespace"
  add_index "configurations", ["value", "name", "namespace"], :name => "index_configurations_on_value", :unique => true

  create_table "file_contents", :force => true do |t|
    t.string  "md5",                      :null => false
    t.string  "sha1",                     :null => false
    t.integer "size",      :default => 0, :null => false
    t.string  "mime_type",                :null => false
  end

  add_index "file_contents", ["md5"], :name => "index_file_contents_on_md5"
  add_index "file_contents", ["mime_type"], :name => "index_file_contents_on_mime_type"
  add_index "file_contents", ["sha1"], :name => "index_file_contents_on_sha1"
  add_index "file_contents", ["size", "sha1", "md5"], :name => "index_file_contents_on_size", :unique => true

  create_table "fingerprints", :force => true do |t|
    t.integer "os_process_count", :default => 0, :null => false
    t.string  "checksum",                        :null => false
  end

  add_index "fingerprints", ["checksum"], :name => "index_fingerprints_on_checksum"

  create_table "hosts", :force => true do |t|
    t.string   "hostname",   :null => false
    t.string   "ip",         :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "hosts", ["ip", "hostname"], :name => "index_hosts_on_ip", :unique => true

  create_table "job_alerts", :force => true do |t|
    t.string  "protocol", :null => false
    t.string  "address",  :null => false
    t.integer "job_id",   :null => false
  end

  add_index "job_alerts", ["job_id"], :name => "index_job_alerts_on_job_id"

  create_table "job_sources", :force => true do |t|
    t.string "name",     :null => false
    t.string "protocol", :null => false
  end

  add_index "job_sources", ["name", "protocol"], :name => "by_unique_name_and_protocol", :unique => true
  add_index "job_sources", ["name"], :name => "index_job_sources_on_name"
  add_index "job_sources", ["protocol"], :name => "index_job_sources_on_protocol"

  create_table "jobs", :force => true do |t|
    t.string   "uuid",                         :null => false
    t.integer  "url_count",     :default => 0, :null => false
    t.datetime "completed_at"
    t.integer  "job_source_id",                :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "jobs", ["completed_at"], :name => "index_jobs_on_completed_at"
  add_index "jobs", ["created_at"], :name => "index_jobs_on_created_at"
  add_index "jobs", ["job_source_id"], :name => "index_jobs_on_job_source_id"
  add_index "jobs", ["uuid"], :name => "by_unique_uuid", :unique => true
  add_index "jobs", ["uuid"], :name => "index_jobs_on_uuid"

  create_table "os", :force => true do |t|
    t.string "name",       :null => false
    t.string "version",    :null => false
    t.string "short_name", :null => false
  end

  add_index "os", ["name", "version", "short_name"], :name => "index_os_on_name", :unique => true

  create_table "os_processes", :force => true do |t|
    t.text    "name",                                  :null => false
    t.integer "pid",                                   :null => false
    t.text    "parent_name"
    t.integer "parent_pid"
    t.integer "process_file_count",     :default => 0, :null => false
    t.integer "process_registry_count", :default => 0, :null => false
    t.integer "fingerprint_id",                        :null => false
  end

  add_index "os_processes", ["fingerprint_id"], :name => "index_os_processes_on_fingerprint_id"
  add_index "os_processes", ["name"], :name => "index_os_processes_on_namenamelength1024"
  add_index "os_processes", ["parent_name"], :name => "index_os_processes_on_nameparent_namelength1024"

  create_table "process_files", :force => true do |t|
    t.text    "name",                                           :null => false
    t.string  "event",                                          :null => false
    t.decimal "time_at",         :precision => 30, :scale => 6, :null => false
    t.integer "file_content_id"
    t.integer "os_process_id",                                  :null => false
  end

  add_index "process_files", ["file_content_id"], :name => "index_process_files_on_file_content_id"
  add_index "process_files", ["name"], :name => "index_process_files_on_namenamelength1024"
  add_index "process_files", ["os_process_id"], :name => "index_process_files_on_os_process_id"

  create_table "process_registries", :force => true do |t|
    t.text    "name",                                         :null => false
    t.string  "event",                                        :null => false
    t.text    "value_name"
    t.string  "value_type"
    t.binary  "value"
    t.decimal "time_at",       :precision => 30, :scale => 6, :null => false
    t.integer "os_process_id",                                :null => false
  end

  add_index "process_registries", ["name"], :name => "index_process_registries_on_namenamelength1024"
  add_index "process_registries", ["os_process_id"], :name => "index_process_registries_on_os_process_id"

  create_table "url_statistics", :force => true do |t|
    t.integer  "count",         :default => 0, :null => false
    t.integer  "url_status_id",                :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "url_statistics", ["count"], :name => "index_url_statistics_on_count"
  add_index "url_statistics", ["created_at", "updated_at", "url_status_id"], :name => "by_unique_range", :unique => true
  add_index "url_statistics", ["created_at"], :name => "index_url_statistics_on_created_at"
  add_index "url_statistics", ["updated_at"], :name => "index_url_statistics_on_updated_at"
  add_index "url_statistics", ["url_status_id"], :name => "index_url_statistics_on_url_status_id"

  create_table "url_statuses", :force => true do |t|
    t.string "status",      :null => false
    t.text   "description", :null => false
  end

  add_index "url_statuses", ["status"], :name => "by_unique_status", :unique => true
  add_index "url_statuses", ["status"], :name => "index_url_statuses_on_status"

  create_table "urls", :force => true do |t|
    t.decimal  "time_at",        :precision => 30, :scale => 6
    t.text     "url",                                                          :null => false
    t.integer  "priority",                                      :default => 1, :null => false
    t.integer  "client_id"
    t.integer  "url_status_id",                                                :null => false
    t.integer  "fingerprint_id"
    t.integer  "job_id",                                                       :null => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "urls", ["client_id"], :name => "index_urls_on_client_id"
  add_index "urls", ["created_at"], :name => "index_urls_on_created_at"
  add_index "urls", ["fingerprint_id"], :name => "index_urls_on_fingerprint_id"
  add_index "urls", ["job_id"], :name => "index_urls_on_job_id"
  add_index "urls", ["priority"], :name => "index_urls_on_priority"
  add_index "urls", ["time_at"], :name => "index_urls_on_time_at"
  add_index "urls", ["url"], :name => "index_urls_on_nameurllength1024"
  add_index "urls", ["url_status_id"], :name => "index_urls_on_url_status_id"

end
