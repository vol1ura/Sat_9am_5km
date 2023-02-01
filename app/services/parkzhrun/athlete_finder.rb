# frozen_string_literal: true

module Parkzhrun
  # Find or create athlete by parkzhrun code
  class AthleteFinder < ApplicationService
    def initialize(code)
      @code = code
    end

    def call
      return unless @code

      athlete = Athlete.find_by(**personal_code.to_params)
      athlete ||= Athlete.find_by(parkrun_code: athlete_info['parkrun_id']) if athlete_info['parkrun_id']
      athlete ||= Athlete.find_by(fiveverst_code: athlete_info['five_verst_id']) if athlete_info['five_verst_id']
      return athlete if athlete

      Athlete.create!(
        name: "#{athlete_info['first_name']} #{athlete_info['last_name'].upcase}",
        male: athlete_info['gender'] == 'male',
        parkrun_code: athlete_info['parkrun_id'],
        fiveverst_code: athlete_info['five_verst_id'],
        **personal_code.to_params
      )
    end

    private

    def personal_code
      @personal_code ||= Athlete::PersonalCode.new(@code)
    end

    def athlete_info
      @athlete_info ||= Client.fetch('athlete', @code)
    end
  end
end
