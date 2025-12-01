class Todo < ApplicationRecord
  belongs_to :objective
  has_many :tasks, dependent: :destroy
end
