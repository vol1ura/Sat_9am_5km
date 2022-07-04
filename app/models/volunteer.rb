# frozen_string_literal: true

class Volunteer < ApplicationRecord
  belongs_to :activity
  belongs_to :athlete

  validates :role, presence: true

  enum role: { director: 0, marshal: 1, timer: 2, photograph: 3, tokens: 4 }

  delegate :name, to: :athlete
end
