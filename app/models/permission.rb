# frozen_string_literal: true

class Permission < ApplicationRecord
  ACTIONS = %w[read create update destroy manage].freeze
  CLASSES = %w[Activity Volunteer Athlete Result].freeze

  belongs_to :user
  belongs_to :event, optional: true

  validates :action, inclusion: ACTIONS
  validates :subject_class, inclusion: CLASSES

  def params
    params = {}
    params[:id] = subject_id if subject_id
    return params unless event_id

    case subject_class
    when 'Activity' then params[:event_id] = event_id
    when 'Result', 'Volunteer' then params[:activity] = { event_id: event_id }
    end

    params
  end
end
