# frozen_string_literal: true

ActiveAdmin.register Activity do
  belongs_to :event, optional: true

  actions :all, except: :destroy
  permit_params :description, :published, :event_id

  menu priority: 3

  filter :date
  filter :event

  scope :all
  scope :published
  scope :unpublished

  form title: 'Загрузка забега', multipart: true, partial: 'form'

  show do
    render 'show', post: activity

    active_admin_comments
  end

  after_create do |activity|
    file_timer = params[:activity][:timer]
    table = CSV.parse(file_timer.read, headers: false)
    activity.date = Date.parse(table[0][1]) # Date of event in the second column of first row
    table[2..].each do |row|
      break if row.first == 'ENDOFEVENT'

      activity.results << Result.new(position: row.first, total_time: row.last)
    end
    activity.save!

    Activity::MAX_SCANNERS.times do |scanner_number|
      file_scanner = params[:activity]["scanner#{scanner_number}".to_sym]
      next unless file_scanner

      table = CSV.parse(file_scanner.read, headers: false)
      table[1..].each do |row|
        code = row.first.delete('A').to_i
        code_type = code < Athlete::FIVE_VERST_BORDER ? :parkrun_code : :fiveverst_code
        athlete = Athlete.find_by(code_type => code)
        position = row.second.delete('P').to_i
        result = activity.results.find_by(position: position)
        # TODO: try to scrape here sites to find athlete
        next unless athlete && result

        result.update!(athlete: athlete)
      end
    end
  end
end
