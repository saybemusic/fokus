class CreateObjectives < ActiveRecord::Migration[7.1]
  def change
    create_table :objectives do |t|
      t.text :system_prompt
      t.string :goal
      t.boolean :completed
      t.text :resume
      t.integer :time_global
      t.integer :time_due
      t.date :completed_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
