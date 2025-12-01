class RemoveCompletedFromObjectives < ActiveRecord::Migration[7.1]
  def change
    remove_column :objectives, :completed, :boolean
  end
end
