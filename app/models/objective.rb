class Objective < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy

  validates :goal, presence: true
  validates :time_global, presence: true
  validates :time_due, presence: true
end
