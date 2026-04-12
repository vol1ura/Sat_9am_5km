# frozen_string_literal: true

module SeasonalTime
  SUMMER_MONTHS = (4..10).freeze

  def summer?
    SUMMER_MONTHS.cover?(month)
  end
end

ActiveSupport::TimeWithZone.include SeasonalTime
