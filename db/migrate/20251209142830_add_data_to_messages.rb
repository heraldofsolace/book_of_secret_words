class AddDataToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :public, :boolean, default: false
    add_column :messages, :pinned, :boolean, default: false
  end
end
