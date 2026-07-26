# frozen_string_literal: true

class ScannerProcessingService < ApplicationService
  def initialize(activity, scanner_file)
    @activity = activity
    @scanner_file = scanner_file
  end

  def call
    return unless @scanner_file

    scanner_data = CSV.parse(@scanner_file.read, headers: false)[1..].filter_map do |row|
      next unless row in [/^A\d+/ => code, /^P\d+/ => position, *]

      { code:, position: }
    end

    ScannerProcessingJob.perform_later @activity.id, scanner_data
  end
end
