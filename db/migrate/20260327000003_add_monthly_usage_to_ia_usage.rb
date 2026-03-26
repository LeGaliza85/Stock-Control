class AddMonthlyUsageToIaUsage < ActiveRecord::Migration[8.1]
  def change
    add_column :ia_usages, :requests_this_month, :integer, default: 0
    add_column :ia_usages, :last_reset_month, :integer, default: 1
  end
end
