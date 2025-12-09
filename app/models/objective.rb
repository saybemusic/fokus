class Objective < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy

  validates :goal, presence: true
  validates :time_global, presence: true
  validates :time_due, presence: true

  def percentage_completion()
    completed_count = todos.where(completed: true).count
    todos_count = todos.count

    (completed_count.fdiv(todos_count) * 100).round()
  end
end
