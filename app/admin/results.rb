# frozen_string_literal: true

ActiveAdmin.register Result do
  belongs_to :activity

  includes :athlete

  actions :all, except: :show

  config.sort_order = 'position_asc'
  config.paginate = false
  config.filters = false

  permit_params :total_time, :position, :athlete_id

  index(
    download_links: [:csv],
    title: -> { "Редактор протокола #{l(@activity.date)}" },
    row_class: ->(r) { 'athlete-error' unless r.correct? },
  ) do
    selectable_column
    column :position
    column :athlete do |result|
      if result.athlete
        external_link_to result.athlete.name.presence || t('common.without_name'), admin_athlete_path(result.athlete)
      else
        external_link_to t('common.without_token'), new_admin_athlete_path(result_id: result.id)
      end
    end
    column :total_time do |result|
      external_link_to human_result_time(result.total_time), edit_admin_activity_result_path(result.activity, result)
    end
    column('Изменение позиции') do |result|
      render partial: 'up_down', locals: { activity: result.activity, result: result } if can?(:manage, result)
    end
    actions(dropdown: true) do |result|
      next unless can?(:manage, result)

      activity = result.activity

      item(
        'Удалить 🔝',
        drop_admin_activity_result_path(activity, result),
        method: :delete,
        data: { confirm: "Удалить строчку №#{result.position} со сдвигом?" },
      )
      item(
        'Удалить 🕑',
        drop_time_admin_activity_result_path(activity, result),
        remote: true,
        method: :delete,
        data: { confirm: 'Удалить время со сдвигом?' },
      )
      item(
        'Удалить 🏃',
        drop_athlete_admin_activity_result_path(activity, result),
        remote: true,
        method: :delete,
        data: { confirm: 'Удалить участника со сдвигом?' },
      )
      if result.athlete_id
        item(
          'Обнулить 🏃',
          reset_athlete_admin_activity_result_path(activity, result),
          remote: true,
          method: :put,
          data: { confirm: 'Сбросить участника на Неизвестного?' },
        )
      end
      item(
        'Добавить 🔝',
        insert_above_admin_activity_result_path(activity, result),
        method: :post,
        data: { confirm: "Вставить новый результат перед #{result.position} позицией?" },
      )
    end
  end

  csv do
    column :position
    column(:code) { |r| r.athlete&.code }
    column(:athlete) { |r| r.athlete&.name }
    column(:gender) { |r| r.athlete&.gender }
    column(:total_time) { |r| human_result_time r.total_time }
  end

  sidebar I18n.t('.results.explanation.title'), only: :index do
    ul do
      li I18n.t('.results.explanation.unknown_athlete')
      li I18n.t('.results.explanation.without_token')
      li I18n.t('.results.explanation.delete_result')
      li I18n.t('.results.explanation.drop_result')
      li I18n.t('.results.explanation.delete_time')
      li I18n.t('.results.explanation.delete_athlete')
      li I18n.t('.results.explanation.reset_athlete')
      li I18n.t('.results.explanation.insert_result')
    end
  end

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

  after_save { |result| result.activity.postprocessing if result.athlete_id }

  after_destroy do |result|
    flash[:notice] = t('.result_destroyed', position: result.position)
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
    @results = resource.shift_attributes!(:athlete_id)
  rescue StandardError
    render js: "alert('#{t 'active_admin.results.drop_athlete_failed'}')"
  end

  member_action :drop, method: :delete, if: proc { can? :manage, Result } do
    resource.transaction do
      collection.where('position > ?', resource.position).update_all('position = position - 1') # rubocop:disable Rails/SkipsModelValidations
      resource.destroy
    end
    redirect_to collection_path, notice: t('active_admin.results.result_successfully_deleted')
  end

  member_action :reset_athlete, method: :put, if: proc { can? :manage, Result } do
    resource.update!(athlete_id: nil)
  rescue StandardError
    render js: "alert('#{t 'active_admin.results.reset_athlete_failed'}')"
  end

  member_action :insert_above, method: :post, if: proc { can? :manage, Result } do
    resource.insert_new_result_above!
    redirect_to collection_path, notice: t('active_admin.results.result_successfully_appended', position: resource.position)
  rescue StandardError => e
    Rollbar.error e
    redirect_to collection_path, alert: t('active_admin.results.insert_result_failed')
  end

  member_action :gender_set, method: :patch, if: proc { can? :manage, Athlete } do
    render js: "alert('#{t 'active_admin.athletes.gender_set_failed'}')" unless resource.athlete.update(male: params[:male])
  end

  action_item :activity, only: :index do
    link_to 'Просмотр забега', admin_activity_path(activity.id)
  end
end
