# frozen_string_literal: true

class Permission < ApplicationRecord
  ACTIONS = %w[read create update destroy manage].freeze
  CLASSES = %w[Activity Volunteer Athlete Result VolunteeringPosition].freeze

  belongs_to :user
  belongs_to :event, optional: true

  validates :action, inclusion: ACTIONS
  validates :subject_class, inclusion: CLASSES

  def params
    options = {}
    options[:id] = subject_id if subject_id
    return options unless event_id

    case subject_class
    when 'Activity' then options[:event_id] = event_id
    when 'Result' then options[:activity] = { event_id: }
    end

    options
  end
end
