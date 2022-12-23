# frozen_string_literal: true

class Volunteer < ApplicationRecord
  ROLES = {
    director: 0, marshal: 1, timer: 2, photograph: 3, tokens: 4, scanner: 5,
    instructor: 6, marking_maker: 7, event_closer: 8, marking_picker: 9, cards_sorter: 10,
    bike_leader: 11, pacemaker: 12, results_handler: 13, equipment_supplier: 14, public_relations: 15,
    warm_up: 16, other: 17, attendant: 18, finish_maker: 19, volunteer_coordinator: 20
  }.freeze

  belongs_to :activity
  belongs_to :athlete

  validates :role, presence: true
  validates :athlete_id, uniqueness: { scope: :activity_id }

  scope :actual, -> { joins(:activity).where(activity: { published: true }) }

  enum role: ROLES, _suffix: true

  delegate :name, to: :athlete, allow_nil: true
end
