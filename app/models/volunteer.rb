# frozen_string_literal: true

class Volunteer < ApplicationRecord
  audited associated_with: :activity, except: :informed

  belongs_to :activity, touch: true
  belongs_to :athlete, touch: true

  validates :role, presence: true
  validates :comment, length: { in: 4..40 }, allow_nil: true
  validates :athlete, uniqueness: { scope: :activity_id }
  validate :cannot_be_assigned_on_more_than_one_position

  before_validation :strip_comment, if: :comment_changed?

  scope :published, -> { joins(:activity).where(activity: { published: true }) }

  enum :role, {
    director: 0, marshal: 1, timer: 2, photograph: 3, tokens: 4, scanner: 5,
    instructor: 6, marking_maker: 7, event_closer: 8, marking_picker: 9, cards_sorter: 10,
    bike_leader: 11, pacemaker: 12, results_handler: 13, equipment_supplier: 14, public_relations: 15,
    warm_up: 16, other: 17, attendant: 18, finish_maker: 19, volunteer_coordinator: 20,
    food_maker: 21, videographer: 22
  }, suffix: true

  delegate :date, to: :activity, allow_nil: true
  delegate :name, to: :athlete, allow_nil: true

  private

  def cannot_be_assigned_on_more_than_one_position
    other_volunteering =
      Volunteer.joins(:activity).where.not(activity_id:).where(athlete_id: athlete_id, activity: { date: })
    errors.add(:athlete, I18n.t('errors.messages.more_than_one_volunteering')) if other_volunteering.exists?
  end

  def strip_comment
    self.comment = comment&.strip.presence
  end
end
