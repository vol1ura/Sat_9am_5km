# frozen_string_literal: true

class Activity < ApplicationRecord
  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results

  validates :date, presence: true

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }

  def add_results_from_timer(file_timer)
    transaction do
      table = CSV.parse(file_timer.read, headers: false)
      activity.date = Date.parse(table[0][1]) # Date of event in the second column of first row
      table[2..].each do |row|
        break if row.first == 'ENDOFEVENT'

        activity.results << Result.new(position: row.first, total_time: row.last)
      end
      activity.save!
    end
  end

  def add_results_from_scanner(file_scanner)
    return unless file_scanner

    table = CSV.parse(file_scanner.read, headers: false)
    table[1..].each do |row|
      code = row.first.delete('A').to_i
      code_type = code < Athlete::FIVE_VERST_BORDER ? :parkrun_code : :fiveverst_code
      athlete = Athlete.find_by(code_type => code)
      position = row.second.delete('P').to_i
      result = activity.results.find_by!(position: position)
      # TODO: try to scrape here sites to find athlete
      next unless athlete

      result.update!(athlete: athlete)
    end
  end
end
