class AddGeminiModelToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :gemini_model, :string, default: "gemini-2.5-flash"
  end
end
