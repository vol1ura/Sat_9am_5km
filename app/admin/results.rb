# frozen_string_literal: true

ActiveAdmin.register Result do
  belongs_to :activity

  includes :athlete, :activity

  actions :all

  config.sort_order = 'position_asc'
  config.paginate = false
  config.filters = false

  permit_params :total_time, :position, :athlete_id

  index download_links: false, title: -> { "Редактор протокола #{l(Activity.find(params[:activity_id]).date)}" } do
    selectable_column
    column :position
    column :athlete do |r|
      if r.athlete
        link_to r.athlete.name, admin_athlete_path(r.athlete), target: '_blank', rel: 'noopener'
      else
        link_to 'БЕЗ ТОКЕНА (создать)', new_admin_athlete_path(result_id: r.id), target: '_blank', rel: 'noopener'
      end
    end
    column :total_time do |r|
      link_to human_result_time(r.total_time),
              edit_admin_activity_result_path(r.activity, r),
              target: '_blank', rel: 'noopener'
    end
    column('Изменение позиции') do |r|
      render partial: 'up_down', locals: { activity: r.activity, result: r }
    end
    actions do |r|
      render partial: 'drops', locals: { activity: r.activity, result: r }
    end
  end

  sidebar I18n.t('active_admin.results.explanation.title'), only: :index do
    ul do
      li I18n.t('active_admin.results.explanation.unknown_athlete')
      li I18n.t('active_admin.results.explanation.without_token')
      li I18n.t('active_admin.results.explanation.delete_result')
      li I18n.t('active_admin.results.explanation.delete_time')
      li I18n.t('active_admin.results.explanation.delete_athlete')
    end
  end

  show { render result }

  form partial: 'form'

  before_update do |result|
    if params[:code].present?
      athlete_code = Athlete::PersonalCode.new(params[:code].to_i)
      athlete = Athlete.find_by(**athlete_code.to_params)
      if athlete
        result.athlete = athlete
      else
        flash[:alert] = I18n.t('active_admin.results.cannot_link_athlete')
      end
    end
  end

  member_action :up, method: :put, if: proc { can? :update, Result } do
    @pred_result = resource.swap_with_position!(resource.position.pred)
  rescue StandardError
    render js: "alert('#{t 'active_admin.results.cannot_move_result'}')"
  end

  member_action :down, method: :put, if: proc { can? :update, Result } do
    @next_result = resource.swap_with_position!(resource.position.next)
  rescue StandardError
    render js: "alert('#{t 'active_admin.results.cannot_move_result'}')"
  end

  member_action :drop_time, method: :delete, if: proc { can? :manage, Result } do
    @results = resource.shift_attributes!(:total_time)
  rescue StandardError
    render js: "alert('#{t 'active_admin.results.drop_time_failed'}')"
  end

  member_action :drop_athlete, method: :delete, if: proc { can? :manage, Result } do
    @results = resource.shift_attributes!(:athlete)
  rescue StandardError
    render js: "alert('#{t 'active_admin.results.drop_athlete_failed'}')"
  end

  action_item :activity, only: :index do
    link_to 'Просмотр забега', admin_activity_path(params[:activity_id])
  end
end
