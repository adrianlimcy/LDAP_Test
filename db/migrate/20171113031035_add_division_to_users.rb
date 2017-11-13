class AddDivisionToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :division, :string
    add_index :users, :division
  end
end
