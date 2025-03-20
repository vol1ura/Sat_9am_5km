# frozen_string_literal: true

class Athlete < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_name, against: :name, using: {
    trigram: { threshold: 0.7, word_similarity: true },
  }

  audited associated_with: :user, max_audits: 20, except: [:stats]

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
  belongs_to :going_to_event, class_name: 'Event', optional: true

  has_many :trophies, dependent: :destroy
  has_many :badges, through: :trophies
  has_many :results, dependent: :nullify
  has_many :activities, through: :results
  has_many :events, through: :activities
  has_many :volunteering, -> { published.order(date: :desc) },
           dependent: :destroy, class_name: 'Volunteer', inverse_of: :athlete

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: :friend_id, dependent: :destroy,
                                 inverse_of: :friend
  has_many :followers, through: :inverse_friendships, source: :athlete

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
            numericality: { only_integer: true, greater_than: PARKZHRUN_BORDER, less_than: SAT_9AM_5KM_BORDER },
            allow_nil: true

  before_save :remove_name_extra_spaces, if: :will_save_change_to_name?
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

    athlete_name = Athletes::Finder.call(personal_code)
    athlete ||= find_or_initialize_by(name: athlete_name, code_type => nil)
    athlete.update!(name: athlete_name, **personal_code.to_params)
    athlete
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[club_id event_id id male name parkrun_code fiveverst_code runpark_code updated_at created_at]
  end

  def code
    parkrun_code || fiveverst_code || runpark_code || (SAT_9AM_5KM_BORDER + id if id)
  end

  def award_by_rage_badge?
    last_total_times = results.published.order(date: :desc).limit(RAGE_BADGE_LIMIT).pluck(:total_time).compact

    last_total_times.size == RAGE_BADGE_LIMIT &&
      last_total_times.each_cons(2).all? { |next_time, prev_time| next_time < prev_time }
  end

  def award_by_five_plus_badge?
    initial_date = Date.current.saturday? ? Date.current : Date.tomorrow.prev_week(:saturday)
    Activity
      .where(id: results.select(:activity_id))
      .or(Activity.where(id: Volunteer.where(athlete: self).select(:activity_id)))
      .where(date: Array.new(5) { |k| initial_date - k.weeks })
      .published
      .select(:date)
      .distinct
      .size == 5
  end

  def gender
    return if male.nil?

    male ? 'мужчина' : 'женщина'
  end

  def going_to_event?
    going_to_event.present?
  end

  def friend?(other_athlete)
    friends.include?(other_athlete)
  end

  private

  def remove_name_extra_spaces
    trimmed_name = name.gsub(/\s+/, ' ').gsub(/^ | $|(?<= ) /, '')
    self.name = trimmed_name unless name == trimmed_name
  end

  def refresh_home_trophies
    trophies.joins(:badge).where(badge: { kind: :home_participating }).destroy_all
    HomeBadgeAwardingJob.perform_later(id) if event_id
  end
end
