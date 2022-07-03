# frozen_string_literal: true

ActiveAdmin.register Activity do
  belongs_to :event, optional: true

  includes :event

  actions :all, except: :destroy
  permit_params :description, :published, :event_id

  menu priority: 3

  filter :date
  filter :event, label: 'Площадка'

  scope :all
  scope :published
  scope :unpublished

  index download_links: false do
    column :date
    column('Где?') { |r| r.event.name }
    column :published
    actions
  end

  form title: 'Загрузка забега', multipart: true, partial: 'form'

  show do
    render 'show', activity: activity
  end

  after_create do |activity|
    activity.add_results_from_timer params[:activity][:timer]
    Activity::MAX_SCANNERS.times do |scanner_number|
      activity.add_results_from_scanner params[:activity]["scanner#{scanner_number}".to_sym]
    end
  end
end
