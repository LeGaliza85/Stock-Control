class CreateIaUsage < ActiveRecord::Migration[8.1]
  def change
    create_table :ia_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ia_service, null: false  # 'gemini' o 'moondream'
      t.integer :requests_today, default: 0
      t.date :last_reset_date, default: -> { 'CURRENT_DATE' }
      t.timestamps
    end

    add_index :ia_usages, [ :user_id, :ia_service ], unique: true
  end
end
