# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity, counter_cache: true, touch: true
  belongs_to :athlete, optional: true, touch: true

  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  scope :published, -> { joins(:activity).where(activity: { published: true }) }
end
