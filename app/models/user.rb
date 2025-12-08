class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :objectives, dependent: :destroy


  def completed_objectives_count
    objectives.where(completed: true).count
  end

  def badge_level
    case completed_objectives_count
    when 0
      :none
    when 1..2
      :bronze
    when 3..4
      :silver
    else
      :gold
    end
  end

  def badge_image
    {
      none:   "debutant.png",
      bronze: "bronze.png",
      silver: "argent.png",
      gold:   "or.png"
    }[badge_level]
  end

  def badge_label
    {
      none:   "Débutant",
      bronze: "Bronze",
      silver: "Argent",
      gold:   "Or"
    }[badge_level]
  end
end
