class TenantsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table "tenants_users", id: false, force: :cascade do |t|
      t.integer "tenant_id", null: false
      t.integer "user_id", null: false
      t.index ["tenant_id","user_id"], name: "index_tenants_users_on_tenant_id_and_user_id"
    end
  end
end
