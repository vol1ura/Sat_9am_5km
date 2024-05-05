# frozen_string_literal: true

class ScannerParser < ApplicationService
  def initialize(activity, scanner_file)
    @activity_id = activity.id
    @scanner_file = scanner_file
  end

  def call
    return unless @scanner_file

    table[1..].each do |row|
      next unless row in [/^A\d+/ => code, /^P\d+/ => position, *]

      AddAthleteToResultJob.perform_later(@activity_id, code, position)
    end
  end

  private

  def table
    @table ||= CSV.parse(@scanner_file.read, headers: false)
  end
end
