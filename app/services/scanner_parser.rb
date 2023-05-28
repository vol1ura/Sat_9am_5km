# frozen_string_literal: true

class ScannerParser < ApplicationService
  def initialize(activity, scanner_file)
    @activity = activity
    @scanner_file = scanner_file
  end

  def call
    return unless @scanner_file
    return unless table.dig(1, 0).match?(/A\d+/)

    table[1..].each do |row|
      next if row.second == 'null' # Athlete was already scanned

      AddAthleteToResultJob.perform_later(@activity, row)
    end
  end

  private

  def table
    @table ||= CSV.parse(@scanner_file.read, headers: false)
  end
end
