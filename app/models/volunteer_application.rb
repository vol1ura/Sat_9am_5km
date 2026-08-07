# frozen_string_literal: true

class VolunteerApplication < ApplicationRecord
  belongs_to :activity
  belongs_to :athlete

  enum :role, Volunteer.roles
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :role, presence: true
  validates :athlete, uniqueness: { scope: :activity_id }
  validate :activity_not_published
  validate :no_conflicting_volunteer, on: :create
  validate :slot_available, on: :create

  after_commit :broadcast_refresh

  def approve!
    transaction do
      Volunteer.create!(activity:, athlete:, role:)
      update!(status: :approved)
      auto_reject_overflow
    end
    VolunteerApplicationMailer.with(application: self).approved.deliver_later
  end

  def reject!
    update!(status: :rejected)
    VolunteerApplicationMailer.with(application: self).rejected.deliver_later
  end

  private

  def activity_not_published
    errors.add(:activity, :published) if activity&.published?
  end

  def no_conflicting_volunteer
    return unless athlete && activity

    existing = Volunteer.joins(:activity).find_by(athlete_id: athlete.id, activity: { date: activity.date })
    errors.add(:athlete, :more_than_one_volunteering) if existing
  end

  def slot_available
    return unless activity && role

    position = activity.volunteering_positions_roster.find { |p| p.role == role }
    return unless position

    filled = activity.volunteers.where(role:).count
    errors.add(:base, :no_slots) if filled >= position.number
  end

  def auto_reject_overflow
    position = activity.volunteering_positions_roster.find { |p| p.role == role }
    return unless position

    return if activity.volunteers.where(role:).count < position.number

    VolunteerApplication.pending.where(activity:, role:).where.not(id:).find_each(&:reject!)
  end

  def broadcast_refresh = broadcast_refresh_later_to :volunteers_roster
end
