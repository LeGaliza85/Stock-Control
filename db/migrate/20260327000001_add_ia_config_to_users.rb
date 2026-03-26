class AddIaConfigToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ia_service, :string, default: "gemini"
    add_column :users, :api_key, :text
    add_column :users, :moondream_mode, :string, default: "cloud"
  end
end
