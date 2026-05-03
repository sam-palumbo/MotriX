class AddGoogleOauthToUsuarios < ActiveRecord::Migration[8.1]
  def change
    change_column_null :usuarios, :password_digest, true
    add_column :usuarios, :google_uid, :string
    add_index :usuarios, :google_uid, unique: true
  end
end
