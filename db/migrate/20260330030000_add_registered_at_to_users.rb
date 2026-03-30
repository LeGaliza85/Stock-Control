class AddRegisteredAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :registered_at, :datetime
  end
end
