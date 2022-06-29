# frozen_string_literal: true

class Activity < ApplicationRecord
  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results

  # validates :date, presence: true

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }

  def add_results_from_timer(file_timer)
    return unless file_timer

    transaction do
      table = CSV.parse(file_timer.read, headers: false)
      self.date = Date.parse(table[0][1]) # Date of event in the second column of first row
      table[2..].each do |row|
        break if row.first == 'ENDOFEVENT'

        results << Result.new(position: row.first, total_time: row.last)
      end
      save!
    end
  end

  def add_results_from_scanner(file_scanner)
    return unless file_scanner

    table = CSV.parse(file_scanner.read, headers: false)
    table[1..].each do |row|
      AddAthleteToResultJob.perform_later(self, row)
    end
  end
end
