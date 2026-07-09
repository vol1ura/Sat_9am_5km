# frozen_string_literal: true

module Metrics
  class VolunteerBusFactorCalculator < ApplicationService
    ROLES = %w[
      director marshal timer photograph tokens scanner instructor marking_maker event_closer
      marking_picker cards_sorter bike_leader pacemaker results_handler equipment_supplier
      warm_up other
    ].freeze

    def initialize(event)
      @event = event
    end

    def call
      ROLES.filter_map do |role|
        volunteers = Volunteer.joins(:activity)
          .where(activity: { event: @event, published: true })
          .where(role:)
          .distinct.count(:athlete_id)

        next if volunteers.zero?

        volunteers * 1.5
      end.max.to_i
    end
  end
end
