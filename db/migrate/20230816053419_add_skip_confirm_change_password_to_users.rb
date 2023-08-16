class AddSkipConfirmChangePasswordToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :skip_confirm_change_password, :boolean, default: false
  end
end
