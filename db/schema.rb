# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_08_223629) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "circus_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "circus_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "invitation_sent_at"
    t.datetime "accepted_at"
    t.boolean "active"
    t.index ["circus_id"], name: "index_circus_users_on_circus_id"
    t.index ["user_id"], name: "index_circus_users_on_user_id"
  end

  create_table "circuses", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "country"
    t.string "currency"
    t.boolean "active", default: true
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.boolean "had_trial", default: false, null: false
    t.string "stripe_subscription_status"
    t.datetime "stripe_current_period_end"
    t.boolean "stripe_cancel_at_period_end"
    t.jsonb "stripe_pause_collection"
    t.index ["stripe_customer_id"], name: "index_circuses_on_stripe_customer_id"
    t.index ["user_id"], name: "index_circuses_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "document_type"
    t.bigint "user_id", null: false
    t.bigint "circus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circus_id"], name: "index_documents_on_circus_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "circus_id", null: false
    t.bigint "sender_id", null: false
    t.text "message"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circus_id"], name: "index_invitations_on_circus_id"
    t.index ["sender_id"], name: "index_invitations_on_sender_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "localities", force: :cascade do |t|
    t.string "title"
    t.string "location"
    t.string "city"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active"
    t.bigint "circus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circus_id"], name: "index_localities_on_circus_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "body"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "circus_id", null: false
    t.string "stripe_payment_method_id", null: false
    t.string "card_brand", null: false
    t.string "last4", null: false
    t.integer "exp_month", null: false
    t.integer "exp_year", null: false
    t.boolean "default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circus_id"], name: "index_payment_methods_on_circus_id"
  end

  create_table "payroll_items", force: :cascade do |t|
    t.bigint "payroll_id", null: false
    t.string "name"
    t.string "job_role"
    t.decimal "amount"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payroll_id"], name: "index_payroll_items_on_payroll_id"
  end

  create_table "payrolls", force: :cascade do |t|
    t.string "title"
    t.date "date"
    t.decimal "total"
    t.bigint "circus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circus_id"], name: "index_payrolls_on_circus_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name", null: false
    t.string "stripe_price_id", null: false
    t.integer "price_cents", null: false
    t.integer "allowed_circuses", null: false
    t.text "features"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trial_days", default: 0, null: false
    t.string "key", null: false
    t.index ["key"], name: "index_plans_on_key", unique: true
    t.index ["stripe_price_id"], name: "index_plans_on_stripe_price_id"
  end

  create_table "subscription_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subscription_id", null: false
    t.string "stripe_subscription_item_id"
    t.string "stripe_product_id"
    t.string "price_id"
    t.string "service_key", default: "core", null: false
    t.integer "quantity", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.integer "unit_amount"
    t.string "currency"
    t.string "interval"
    t.integer "interval_count"
    t.index ["service_key"], name: "index_subscription_items_on_service_key"
    t.index ["stripe_subscription_item_id"], name: "index_subscription_items_on_stripe_subscription_item_id", unique: true
    t.index ["subscription_id", "service_key"], name: "idx_one_active_item_per_service", unique: true, where: "(active = true)"
    t.index ["subscription_id", "service_key"], name: "uniq_active_item_per_service_per_subscription", unique: true, where: "(active = true)"
    t.index ["subscription_id"], name: "index_subscription_items_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "circus_id", null: false
    t.string "stripe_subscription_id", null: false
    t.string "status", null: false
    t.datetime "current_period_start", null: false
    t.datetime "current_period_end", null: false
    t.string "price_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "checkout_session_id"
    t.string "stripe_customer_id"
    t.boolean "active", default: false, null: false
    t.boolean "cancel_at_period_end", default: false, null: false
    t.string "latest_invoice_id"
    t.string "latest_invoice_status"
    t.string "latest_charge_id"
    t.datetime "paid_through_at"
    t.index ["checkout_session_id"], name: "index_subscriptions_on_checkout_session_id", unique: true
    t.index ["circus_id"], name: "index_subscriptions_on_circus_id"
    t.index ["circus_id"], name: "index_subscriptions_one_active_per_circus", unique: true, where: "(active = true)"
    t.index ["circus_id"], name: "uniq_active_subscription_per_circus", unique: true, where: "(active = true)"
    t.index ["price_id"], name: "index_subscriptions_on_price_id"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.string "title"
    t.decimal "amount", precision: 10, scale: 2
    t.string "transaction_type"
    t.text "description"
    t.datetime "date"
    t.bigint "user_id", null: false
    t.bigint "circus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.bigint "locality_id", null: false
    t.bigint "payroll_id"
    t.index ["circus_id"], name: "index_transactions_on_circus_id"
    t.index ["locality_id"], name: "index_transactions_on_locality_id"
    t.index ["payroll_id"], name: "index_transactions_on_payroll_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name"
    t.string "address"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "web"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "inviting_circus_id"
    t.boolean "superadmin", default: false, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "stripe_subscription_id"
    t.boolean "had_trial", default: false, null: false
    t.integer "circuses_count", default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "circus_users", "circuses"
  add_foreign_key "circus_users", "users"
  add_foreign_key "circuses", "users"
  add_foreign_key "documents", "circuses"
  add_foreign_key "documents", "users"
  add_foreign_key "invitations", "circuses"
  add_foreign_key "invitations", "users"
  add_foreign_key "invitations", "users", column: "sender_id"
  add_foreign_key "localities", "circuses"
  add_foreign_key "notifications", "users"
  add_foreign_key "payment_methods", "circuses"
  add_foreign_key "payroll_items", "payrolls"
  add_foreign_key "payrolls", "circuses"
  add_foreign_key "subscription_items", "subscriptions"
  add_foreign_key "subscriptions", "circuses"
  add_foreign_key "taggings", "tags"
  add_foreign_key "transactions", "circuses"
  add_foreign_key "transactions", "localities"
  add_foreign_key "transactions", "payrolls"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_profiles", "users"
end
