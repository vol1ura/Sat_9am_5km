# frozen_string_literal: true

class Permission < ApplicationRecord
  ACTIONS = %w[read create update destroy manage].freeze
  CLASSES = %w[Activity Volunteer Athlete Result VolunteeringPosition Club].freeze

  belongs_to :user
  belongs_to :event, optional: true

  validates :action, inclusion: ACTIONS
  validates :subject_class, inclusion: CLASSES
end
