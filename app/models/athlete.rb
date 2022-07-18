# frozen_string_literal: true

class Athlete < ApplicationRecord
  FIVE_VERST_BORDER = 790000000
  NOBODY = 'НЕИЗВЕСТНЫЙ'

  belongs_to :club, optional: true
  belongs_to :user, optional: true

  has_many :trophies, dependent: :destroy
  has_many :badges, through: :trophies
  has_many :results, dependent: :nullify
  has_many :activities, through: :results
  has_many :events, through: :activities
  has_many :volunteering, -> { joins(:activity).where(activity: { published: true }).order('activity.date DESC') },
           dependent: :destroy, class_name: 'Volunteer', inverse_of: :athlete

  validates :parkrun_code, uniqueness: true, allow_nil: true
  validates :fiveverst_code, uniqueness: true, allow_nil: true

  before_validation :fill_blank_name, if: -> { name.blank? }

  def self.duplicates
    namesakes = find_by_sql('SELECT LOWER(name) AS l_name FROM athletes GROUP BY l_name HAVING COUNT(*) > 1').pluck(:l_name)
    namesakes_ids = where('LOWER(name) in (?)', namesakes)
                    .pluck(:name, :id, :parkrun_code)
                    .group_by { |n| n.first.downcase }
                    .filter { |_, arr| arr.map(&:last).include?(nil) }
                    .flat_map { |_, arr| arr.map(&:second) }
    where(id: namesakes_ids).order(:name)
  end

  def self.find_or_scrape_by_code!(code)
    code_type = code < FIVE_VERST_BORDER ? :parkrun_code : :fiveverst_code
    rec = find_by(code_type => code)
    return rec if rec && rec.name != NOBODY

    athlete_name = AthleteFinder.call(code_type: code_type, code: code)
    rec ||= find_or_initialize_by(name: athlete_name, code_type => nil)
    rec.update!(code_type => code, name: athlete_name)
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
