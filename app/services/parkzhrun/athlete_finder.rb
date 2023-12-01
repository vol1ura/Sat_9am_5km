# frozen_string_literal: true

module Parkzhrun
  # Find or create athlete by parkzhrun code
  class AthleteFinder < ApplicationService
    def initialize(code)
      @code = code
    end

    def call
      return unless @code
      return athlete if find_athlete_by_code || find_athlete_by_info

      Athlete.create!(
        name: "#{athlete_info['first_name']} #{athlete_info['last_name'].upcase}",
        male: athlete_info['gender'] == 'male',
        parkrun_code: athlete_info['parkrun_id'],
        fiveverst_code: athlete_info['five_verst_id'],
        **personal_code.to_params,
      )
    end

    private

    attr_reader :athlete

    def find_athlete_by_code
      @athlete = Athlete.find_by(**personal_code.to_params)
    end

    def find_athlete_by_info
      @athlete = Athlete.find_by(parkrun_code: athlete_info['parkrun_id']) if athlete_info['parkrun_id']
      @athlete ||= Athlete.find_by(fiveverst_code: athlete_info['five_verst_id']) if athlete_info['five_verst_id']
      @athlete
    end

    def personal_code
      @personal_code ||= Athlete::PersonalCode.new(@code)
    end

    def athlete_info
      @athlete_info ||= Client.fetch('athlete', @code)
    end
  end
end
