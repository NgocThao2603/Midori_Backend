class AddAvatarUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :avatar_url, :string, default: "/avatars/avatar.svg"
  end
end
