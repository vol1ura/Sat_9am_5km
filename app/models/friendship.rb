class Friendship < ApplicationRecord
  belongs_to :athlete
  belongs_to :friend, class_name: 'Athlete'

  validates :athlete_id, uniqueness: { scope: :friend_id }
  validate :not_self_friendship

  private

  def not_self_friendship
    errors.add(:friend_id, :invalid) if athlete_id == friend_id
  end
end
