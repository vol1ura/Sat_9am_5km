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

  after_create do |activity|
    # byebug

    # file_timer = params[:activity][:timer]
    # table = CSV.parse(file_timer.read, headers: false)
    # activity.date = Date.parse(table[0][1]) # Date of event in the second column of first row
    # table[2..].each do |row|
    #   activity.results << Result.new(total_time: row.last)
    # end

    Activity::MAX_SCANNERS.times do |scanner_number|
      file_scanner = params[:activity]["scanner#{scanner_number}".to_sym]
      next unless file_scanner

      table = CSV.parse(file_scanner.read, headers: false)
      table[1..].each do |row|
        user = User.find_or_create_by(parkrun_id: row.first) do

        end
      end
    end
  end
end
