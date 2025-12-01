class AddCompletedToObjectives < ActiveRecord::Migration[7.1]
  def change
    add_column :objectives, :completed, :boolean, default: false
  end
end
