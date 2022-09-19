# frozen_string_literal: true

class Athlete < ApplicationRecord
  SAT_5AM_9KM_BORDER = 770_000_000
  FIVE_VERST_BORDER = 790_000_000
  RUN_PARK_BORDER = 7_000_000_000
  NOBODY = 'НЕИЗВЕСТНЫЙ'

  PersonalCode = Struct.new(:code) do
    def code_type
      @code_type ||=
        if code < SAT_5AM_9KM_BORDER
          :parkrun_code
        # elsif code > RUN_PARK_BORDER
        #   :runpark_code
        elsif code > FIVE_VERST_BORDER
          :fiveverst_code
        else
          :id
        end
    end

    def id
      @id ||= code.between?(SAT_5AM_9KM_BORDER, FIVE_VERST_BORDER) ? code - SAT_5AM_9KM_BORDER : code
    end

    def to_params
      @to_params ||= { code_type => id }
    end
  end

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
  before_save :remove_extra_spaces, if: :will_save_change_to_name?

  def self.duplicates
    sql = <<~SQL.squish
      SELECT id, parkrun_code, fiveverst_code, l_name FROM (
        SELECT id, parkrun_code, fiveverst_code, l_name, COUNT(id) OVER (PARTITION BY l_name) AS cnt FROM (
          SELECT *, array(SELECT unnest(string_to_array(LOWER(name), ' ')) ORDER BY 1) AS l_name FROM athletes
        ) AS q1
      ) AS q2
      WHERE q2.cnt > 1
    SQL
    namesakes_ids = find_by_sql(sql)
                    .pluck(:l_name, :id, :parkrun_code, :fiveverst_code)
                    .group_by(&:first)
                    .reject { |_, arr| arr.all?(&:third) || arr.all?(&:last) }
                    .flat_map { |_, arr| arr.map(&:second) }
    where(id: namesakes_ids)
  end

  def self.find_or_scrape_by_code!(code)
    personal_code = PersonalCode.new(code)
    code_type = personal_code.code_type
    athlete = find_by(**personal_code.to_params)
    return athlete if athlete && (athlete.name != NOBODY || code_type == :id)
    return create if code_type == :id

    athlete_name = AthleteFinder.call(personal_code)
    athlete ||= find_or_initialize_by(name: athlete_name, code_type => nil)
    athlete.update!(name: athlete_name, **personal_code.to_params)
    athlete
  end

  def personal_best(key = :total_time)
    results.published.order(key).first
  end

  def code
    parkrun_code || fiveverst_code || (SAT_5AM_9KM_BORDER + id if id)
  end

  def gender
    return if male.nil?

    male ? 'мужчина' : 'женщина'
  end

  private

  def fill_blank_name
    self.name = NOBODY
  end

  def remove_extra_spaces
    trimmed_name = name.gsub(/\s+/, ' ').gsub(/^ | $|(?<= ) /, '')
    self.name = trimmed_name unless name == trimmed_name
  end
end
