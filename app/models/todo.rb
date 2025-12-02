class Todo < ApplicationRecord
  belongs_to :objective
  has_many :tasks, dependent: :destroy

  def to_ordered_day
    (due_date - self.objective.created_at.to_date).to_i + 1
  end
end
