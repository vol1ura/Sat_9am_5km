# frozen_string_literal: true

class Metrics::VolunteerBusFactorCalculator < ApplicationService
  def call(event)
    roles = %w[director marshal timer photograph tokens scanner instructor marking_maker event_closer marking_picker cards_sorter bike_leader pacemaker results_handler equipment_supplier warm_up other]
    
    max_bus_factor = 0
    
    roles.each do |role|
      volunteers = Volunteer.joins(:activity)
        .where(activity: { event: event, published: true })
        .where(role: role)
        .distinct.count(:athlete_id)
      
      next if volunteers.zero?
      
      bus_factor = volunteers * 1.5
      max_bus_factor = [bus_factor, max_bus_factor].max
    end
    
    max_bus_factor
  end
end
