# frozen_string_literal: true

class Volunteer < ApplicationRecord
  ROLES = { director: 0, marshal: 1, timer: 2, photograph: 3, tokens: 4 }.freeze

  belongs_to :activity
  belongs_to :athlete

  validates :role, presence: true

  enum role: ROLES

  delegate :name, to: :athlete
end
