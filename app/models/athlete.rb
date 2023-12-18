# frozen_string_literal: true

class Athlete < ApplicationRecord
  audited associated_with: :user, max_audits: 20

  PARKZHRUN_BORDER = 690_000_000
  SAT_9AM_5KM_BORDER = 770_000_000
  FIVE_VERST_BORDER = 790_000_000
  RUN_PARK_BORDER = 7_000_000_000

  RAGE_BADGE_LIMIT = 3

  PersonalCode = Struct.new(:code) do
    def code_type
      @code_type ||=
        if code < PARKZHRUN_BORDER
          :parkrun_code
        elsif code < SAT_9AM_5KM_BORDER
          :parkzhrun_code
        elsif code > RUN_PARK_BORDER
          :runpark_code
        elsif code > FIVE_VERST_BORDER
          :fiveverst_code
        else
          :id
        end
    end

    def id
      @id ||= code.between?(SAT_9AM_5KM_BORDER, FIVE_VERST_BORDER) ? code - SAT_9AM_5KM_BORDER : code
    end

    def to_params
      @to_params ||= { code_type => id }
    end
  end

  belongs_to :club, optional: true
  belongs_to :user, optional: true
  belongs_to :event, optional: true

  has_many :trophies, dependent: :destroy
  has_many :badges, through: :trophies
  has_many :results, dependent: :nullify
  has_many :activities, through: :results
  has_many :events, through: :activities
  has_many :volunteering, -> { published.order(date: :desc) },
           dependent: :destroy, class_name: 'Volunteer', inverse_of: :athlete

  validates :parkrun_code,
            uniqueness: true,
            numericality: { only_integer: true, less_than: PARKZHRUN_BORDER },
            allow_nil: true
  validates :fiveverst_code,
            uniqueness: true,
            numericality: { only_integer: true, greater_than: FIVE_VERST_BORDER, less_than: RUN_PARK_BORDER },
            allow_nil: true
  validates :runpark_code,
            uniqueness: true,
            numericality: { only_integer: true, greater_than: RUN_PARK_BORDER },
            allow_nil: true
  validates :parkzhrun_code,
            uniqueness: true,
            numericality: { only_integer: true, greater_than: PARKZHRUN_BORDER },
            allow_nil: true

  before_save :remove_extra_spaces, if: :will_save_change_to_name?
  after_commit :refresh_home_trophies, if: :saved_change_to_event_id?

  def self.duplicates
    sql = <<~SQL.squish
      SELECT id, parkrun_code, fiveverst_code, l_name FROM (
        SELECT id, parkrun_code, fiveverst_code, l_name, COUNT(id) OVER (PARTITION BY l_name) AS cnt FROM (
          SELECT *, array(SELECT unnest(string_to_array(LOWER(name), ' ')) ORDER BY 1) AS l_name FROM athletes
        ) AS q1
      ) AS q2
      WHERE q2.cnt > 1
    SQL
    namesakes_ids =
      find_by_sql(sql)
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
    return athlete if athlete && (athlete.name || code_type == :id)
    return create if code_type == :id

    athlete_name = AthleteFinder.call(personal_code)
    athlete ||= find_or_initialize_by(name: athlete_name, code_type => nil)
    athlete.update!(name: athlete_name, **personal_code.to_params)
    athlete
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[club_id created_at event_id fiveverst_code id male name parkrun_code runpark_code updated_at]
  end

  def code
    parkrun_code || fiveverst_code || runpark_code || (SAT_9AM_5KM_BORDER + id if id)
  end

  def award_by_rage_badge?
    last_total_times = results.published.order('activity.date DESC').limit(RAGE_BADGE_LIMIT).pluck(:total_time).compact

    last_total_times.size == RAGE_BADGE_LIMIT &&
      last_total_times.each_cons(2).all? { |next_time, prev_time| next_time < prev_time }
  end

  def gender
    return if male.nil?

    male ? 'мужчина' : 'женщина'
  end

  private

  def remove_extra_spaces
    trimmed_name = name.gsub(/\s+/, ' ').gsub(/^ | $|(?<= ) /, '')
    self.name = trimmed_name unless name == trimmed_name
  end

  def refresh_home_trophies
    trophies.joins(:badge).where(badge: { kind: :home_participating }).destroy_all
    HomeBadgeAwardingJob.perform_later(id) if event_id
  end
end
