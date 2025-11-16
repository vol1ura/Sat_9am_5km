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
    # Small notice about new drag-and-drop participant reordering.
    div class: 'arctic-migration-notice' do
      span class: 'arctic-badge' do
        'НОВОЕ'
      end
      span class: 'arctic-message' do
        'Добавлена возможность перетаскивать участников — при переносе перемещается только участник, а время остаётся на позиции.'
      end
    end
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
        'Удалить 🆙',
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

  sidebar 'Внимание!', only: :index, if: proc { Activity.published.exists?(params[:activity_id]) } do
    div(
      'Забег опубликован. Редактирование протокола сейчас может привести
      к логическим ошибкам в статистике и некорректному награждению.',
      class: 'warning-box',
    )
  end

  sidebar I18n.t('.results.explanation.actions.title'), only: :index do
    ul do
      I18n.t('.results.explanation.actions.items').each { |item| li item }
    end
  end

  sidebar I18n.t('.results.explanation.batch_actions.title'), only: :index do
    ul do
      I18n.t('.results.explanation.batch_actions.items').each { |item| li item }
    end
  end

  sidebar I18n.t('.results.explanation.important.title'), only: :index do
    ul do
      I18n.t('.results.explanation.important.items').each { |item| li item }
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
      collection.where('position > ?', resource.position).update_all 'position = position - 1'
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

  collection_action :reorder, method: :post, if: proc { can? :update, Result } do
    ids = Array(params[:order]).map(&:to_i)
    activity = Activity.find(params[:activity_id])

    # We want to move participants (athlete_id) between fixed position rows
    # while keeping the total_time anchored to positions. To do that we:
    # 1. collect athlete_ids for the given result ids in the requested order
    # 2. nulify athlete_id for all results in the activity
    # 3. assign athlete_ids to results in position order according to the requested order
    results = activity.results.order(:position).to_a
    source_map = Result.where(id: ids).pluck(:id, :athlete_id).to_h

    ActiveRecord::Base.transaction do
      # clear existing athlete assignments to avoid uniqueness conflicts
      Result.where(id: results.map(&:id)).update_all(athlete_id: nil)

      # snapshot total_time by result id to ensure we don't accidentally move times
      before_times = Result.where(id: results.map(&:id)).pluck(:id, :total_time).to_h

      results.each_with_index do |res, idx|
        src_id = ids[idx]
        next unless src_id

        athlete_id = source_map[src_id]
        # assign athlete_id directly via update_columns to avoid callbacks (which may change times)
        res.update_columns(athlete_id:) if athlete_id.present?
      end

      # verify times didn't change during the operation
      after_times = Result.where(id: results.map(&:id)).pluck(:id, :total_time).to_h
      raise 'Invariant violation: total_time changed during reorder' if before_times != after_times
    end

    render json: { updated: ids }, status: :ok
  rescue StandardError => e
    Rails.logger.error 'Results reorder failed: ', e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  member_action :gender_set, method: :patch, if: proc { can? :manage, Athlete } do
    render js: "alert('#{t 'active_admin.athletes.gender_set_failed'}')" unless resource.athlete.update(male: params[:male])
  end

  action_item :activity, only: :index do
    link_to 'Просмотр забега', admin_activity_path(activity.id)
  end

  batch_action(
    :destroy,
    confirm: I18n.t('active_admin.results.batch_destroy_confirm'),
    if: proc { !parent.published },
  ) do |ids|
    Result.without_auditing do
      batch_action_collection.where(id: ids).destroy_all
    end
    redirect_to(
      collection_path(parent),
      notice: t(
        'active_admin.batch_actions.succesfully_destroyed',
        count: ids.count,
        model: t('activerecord.models.result.one'),
        plural_model: t('activerecord.models.result.many'),
      ),
    )
  end

  batch_action(
    :move_time,
    confirm: I18n.t('active_admin.results.batch_move_time_confirm'),
    if: proc { !parent.published },
    form: {
      type: [%w[Добавить up], %w[Отнять down]],
      minutes: 60.times.map,
      seconds: 60.times.map,
    },
  ) do |ids, inputs|
    sign = inputs[:type] == 'up' ? '+' : '-'
    delta = (inputs[:minutes].to_i * 60) + inputs[:seconds].to_i
    Result.where(id: ids).update_all("total_time = total_time #{sign} INTERVAL '#{delta} seconds'")

    redirect_to(
      collection_path(parent),
      notice: I18n.t(
        'active_admin.batch_actions.successfully_moved_time',
        sign: sign,
        delta: delta,
        count: ids.count,
      ),
    )
  end
end
