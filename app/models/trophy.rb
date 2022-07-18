# frozen_string_literal: true

class Trophy < ApplicationRecord
  belongs_to :badge
  belongs_to :athlete

  validates :athlete_id, uniqueness: { scope: :badge_id }
end
