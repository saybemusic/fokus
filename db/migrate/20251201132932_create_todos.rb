class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :description
      t.boolean :completed, default: false
      t.date :due_date
      t.date :completed_at
      t.references :objective, null: false, foreign_key: true

      t.timestamps
    end
  end
end
