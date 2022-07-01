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
    rec.name = athlete_name
    rec.save!
    rec
  end

  def gender
    return if male.nil?

    male ? 'мужчина' : 'женщина'
  end

  private

  def fill_blank_name
    self.name = NOBODY
  end
end
