class RemoveRedundantIndexFromIaUsages < ActiveRecord::Migration[8.1]
  def change
    remove_index :ia_usages, :user_id, name: "index_ia_usages_on_user_id"
  end
end
