# frozen_string_literal: true

ActiveAdmin.register Activity do
  includes :event

  permit_params :description, :published, :event_id, :date

  menu priority: 3

  filter :date
  filter :event, label: 'Забег', collection: proc { Event.authorized_for(current_user) }

  scope :all
  scope :published
  scope(:unpublished) { |scope| scope.where(published: false) }

  config.batch_actions = false
  config.sort_order = 'date_desc'

  index download_links: false do
    column :date
    column 'Где?', &:event_name
    column :published
    actions
  end

  show(title: ->(a) { "Забег №#{a.number}" }) { render activity }

  form title: 'Загрузка забега', multipart: true, partial: 'form'

  after_save do |activity|
    TimerParser.call(activity, params[:activity][:timer])
    Activity::MAX_SCANNERS.times do |scanner_number|
      ScannerParser.call(activity, params[:activity]["scanner#{scanner_number}".to_sym])
    end
    flash[:notice] = params[:activity][:scanner0] ? t('.success_upload') : t('.success_created')
  end

  action_item :results, only: %i[show edit] do
    link_to 'Редактор результатов', admin_activity_results_path(resource)
  end

  action_item :volunteers, only: %i[show edit] do
    link_to 'Редактор волонтёров', admin_activity_volunteers_path(resource)
  end
end
