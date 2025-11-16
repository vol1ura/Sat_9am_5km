# frozen_string_literal: true

class Club < ApplicationRecord
  belongs_to :country
  has_many :athletes, dependent: :nullify

  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [60, 60]
    attachable.variant :web, resize_to_limit: [300, 300], preprocessed: true
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :logo, size: { less_than: 250.kilobytes }, dimension: { width: { in: 150..900 }, height: { in: 150..900 } }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name country_id athletes_count results_count volunteering_count]
  end

  def to_combobox_display = name

  ransacker :athletes_count do
    Arel.sql(
      '(
        SELECT COUNT(athletes.id)
        FROM athletes
        WHERE athletes.club_id = clubs.id
      )',
    )
  end

  ransacker :results_count do
    Arel.sql(
      '(
        SELECT COUNT(results.id)
        FROM results
        INNER JOIN athletes ON athletes.id = results.athlete_id
        INNER JOIN activities ON activities.id = results.activity_id
        WHERE athletes.club_id = clubs.id AND activities.published = TRUE
      )',
    )
  end

  ransacker :volunteering_count do
    Arel.sql(
      '(
        SELECT COUNT(volunteers.id)
        FROM volunteers
        INNER JOIN athletes ON athletes.id = volunteers.athlete_id
        INNER JOIN activities ON activities.id = volunteers.activity_id
        WHERE athletes.club_id = clubs.id AND activities.published = TRUE
      )',
    )
  end
end
