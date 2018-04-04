class CreateTodos < ActiveRecord::Migration[5.2]
  def change
    create_table :todos do |t|
      t.text :body
      t.boolean :complete

      t.timestamps
    end
  end
end
