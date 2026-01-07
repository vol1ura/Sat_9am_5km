# frozen_string_literal: true

module Parkzhrun
  # Find or create athlete by parkzhrun code
  class AthleteFinder < ApplicationService
    def initialize(code)
      @code = code
    end

    def call
      return unless @code
      return @athlete if find_athlete_by_code

      if find_athlete_by_info
        update_athlete_by_info
        return @athlete
      end

      Athlete.create!(
        name: "#{athlete_info[:first_name]} #{athlete_info[:last_name].upcase}",
        gender: athlete_info[:gender],
        parkrun_code: athlete_info[:parkrun_id],
        fiveverst_code: athlete_info[:five_verst_id],
        runpark_code: athlete_info[:runpark_id],
        **personal_code.to_params,
      )
    end

    private

    def find_athlete_by_code
      @athlete = Athlete.find_by(**personal_code.to_params)
    end

    def update_athlete_by_info
      @athlete.parkrun_code ||= athlete_info[:parkrun_id]
      @athlete.fiveverst_code ||= athlete_info[:five_verst_id]
      @athlete.runpark_code ||= athlete_info[:runpark_id]
      @athlete.parkzhrun_code ||= athlete_info[:parkzhrun_id]
      Rollbar.warn("Can't update athlete using ParkZhrun info", athlete_id: @athlete.id) unless @athlete.save
    end

    def find_athlete_by_info
      @athlete = Athlete.find_by(id: athlete_info[:s95_id] - Athlete::SAT_9AM_5KM_BORDER) if athlete_info[:s95_id]
      @athlete ||= Athlete.find_by(parkrun_code: athlete_info[:parkrun_id]) if athlete_info[:parkrun_id]
      @athlete ||= Athlete.find_by(fiveverst_code: athlete_info[:five_verst_id]) if athlete_info[:five_verst_id]
      @athlete ||= Athlete.find_by(runpark_code: athlete_info[:runpark_id]) if athlete_info[:runpark_id]
      @athlete
    end

    def personal_code
      @personal_code ||= Athlete::PersonalCode.new(@code)
    end

    def athlete_info
      @athlete_info ||= Client.fetch(:athlete, @code)
    end
  end
end
