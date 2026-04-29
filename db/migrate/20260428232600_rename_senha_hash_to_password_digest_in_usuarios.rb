class RenameSenhaHashToPasswordDigestInUsuarios < ActiveRecord::Migration[8.0]
  def change
    rename_column :usuarios, :senha_hash, :password_digest
  end
end
