# frozen_string_literal: true

ActiveAdmin.register Activity do
  includes :event

  permit_params :description, :published, :event_id, :date

  menu priority: 2

  filter :date
  filter :event, label: 'Забег', collection: proc { Event.authorized_for(current_user) }

  scope :all
  scope :published
  scope(:unpublished) { |s| s.where(published: false) }

  config.batch_actions = false
  config.sort_order = 'date_desc'

  index download_links: false do
    column :date
    column :event_name
    column :published
    actions
  end

  show(title: ->(a) { "Забег №#{a.number}" }) { render activity }

  form title: 'Загрузка забега', multipart: true, partial: 'form'

  controller do
    def destroy
      return super unless resource.published?

      flash[:error] = t '.forbidden_for_published'
      redirect_to resource_path
    end
  end

  after_save do |activity|
    if activity.valid?
      TimerParser.call(activity, params[:activity][:timer])
      Activity::MAX_SCANNERS.times do |number|
        ScannerParser.call(activity, params[:activity]["scanner#{number}"])
      end
      flash[:notice] = t('.success_upload') if params[:activity][:timer] || params[:activity][:scanner0]
    end
  rescue CSV::MalformedCSVError => e
    Rollbar.error e
    flash[:error] = t('.failed_upload')
  rescue TimerParser::FormatError
    flash[:error] = t('.bad_timer_format')
  rescue ActiveRecord::RecordInvalid
    flash[:error] = t('.bad_data')
  end

  action_item :results, only: %i[show edit] do
    link_to 'Редактор результатов', admin_activity_results_path(resource)
  end

  action_item :volunteers, only: %i[show edit] do
    link_to 'Редактор волонтёров', admin_activity_volunteers_path(resource)
  end

  action_item :publish, only: :show do
    next if resource.published || !resource.correct?

    link_to(
      'Опубликовать',
      publish_admin_activity_path(resource),
      method: :put,
      data: { confirm: t('admin.activities.publish.confirm') },
    )
  end

  member_action :publish, method: :put do
    if resource.results.empty?
      flash[:error] = t '.empty_protocol'
    elsif resource.correct?
      resource.update!(published: true)
      flash[:notice] = t '.successfully_published'
    else
      flash[:error] = t '.incorrect_protocol'
    end
    redirect_to admin_activity_path(resource)
  end
end
