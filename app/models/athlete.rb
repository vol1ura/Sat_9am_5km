# frozen_string_literal: true

class Athlete < ApplicationRecord
  FIVE_VERST_BORDER = 790000000
  NOBODY = 'НЕИЗВЕСТНЫЙ'

  belongs_to :club, optional: true
  belongs_to :user, optional: true

  has_many :results, dependent: :nullify
  has_many :activities, through: :results
  has_many :events, through: :activities
  has_many :volunteering, dependent: :destroy, class_name: 'Volunteer'

  validates :parkrun_code, uniqueness: true, allow_nil: true
  validates :fiveverst_code, uniqueness: true, allow_nil: true

  before_validation :fill_blank_name, if: -> { name.blank? }

  def self.find_or_scrape_by_code!(code)
    code_type = code < FIVE_VERST_BORDER ? :parkrun_code : :fiveverst_code
    rec = find_by(code_type => code)
    return rec if rec && rec.name != NOBODY

    athlete_name = ::Finder::Athlete.call(code_type: code_type, code: code)
    rec ||= find_or_initialize_by(name: athlete_name, code_type => nil)
    rec.update!(code_type => code, name: athlete_name)
    rec
  end

  def self.reunite(collection, athletes_ids)
    athlete = collection.where.not(name: nil).take
    return false unless athlete

    athlete.send(:grab_fields_from, collection)
    transaction do
      Result.where(athlete_id: athletes_ids).update_all(athlete_id: athlete.id) # rubocop:disable Rails/SkipsModelValidations
      Volunteer.where(athlete_id: athletes_ids).update_all(athlete_id: athlete.id) # rubocop:disable Rails/SkipsModelValidations
      collection.where.not(id: athlete.id).destroy_all
      athlete.save or raise ActiveRecord::Rollback
    end
  end

  def gender
    return if male.nil?

    male ? 'мужчина' : 'женщина'
  end

  private

  def fill_blank_name
    self.name = NOBODY
  end

  def grab_fields_from(collection)
    self.parkrun_code ||= collection.where.not(parkrun_code: nil).take&.parkrun_code
    self.fiveverst_code ||= collection.where.not(fiveverst_code: nil).take&.fiveverst_code
    self.user_id ||= collection.where.not(user_id: nil).take&.user_id
    self.male ||= collection.where.not(male: nil).take&.male
  end
end
