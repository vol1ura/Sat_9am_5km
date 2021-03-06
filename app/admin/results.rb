# frozen_string_literal: true

ActiveAdmin.register Result do
  belongs_to :activity

  includes :athlete, activity: :event

  actions :all

  config.sort_order = 'position_asc'
  config.paginate = false
  config.filters = false

  permit_params :total_time, :position, :athlete_id

  index download_links: false do
    selectable_column
    column :position
    column :athlete
    column(:total_time) { |r| human_result_time(r.total_time) }
    column('Изменение позиции') do |r|
      render partial: 'up_down', locals: { activity: activity, result: r }
    end
    column('Забег') { |r| human_activity_name(r.activity) }
    actions
  end

  show { render result }

  form partial: 'form'

  before_update do |result|
    if params[:parkrun_code].present? || params[:fiveverst_code].present?
      athlete = Athlete.find_by parkrun_code: params[:parkrun_code].to_s.strip if params[:parkrun_code].present?
      athlete ||= Athlete.find_by fiveverst_code: params[:fiveverst_code].to_s.strip if params[:fiveverst_code].present?
      if athlete
        result.athlete = athlete
      else
        flash[:alert] = I18n.t('active_admin.results.cannot_link_athlete')
      end
    end
  end

  member_action :up, method: :put, if: proc { can? :manage, Result } do
    @pred_result = resource.swap_with_position(resource.position.pred)
  rescue StandardError
    render js: "alert('#{I18n.t 'active_admin.results.cannot_move_result'}')"
  end

  member_action :down, method: :put, if: proc { can? :manage, Result } do
    @next_result = resource.swap_with_position(resource.position.next)
  rescue StandardError
    render js: "alert('#{I18n.t 'active_admin.results.cannot_move_result'}')"
  end

  action_item :activity, only: :index do
    link_to 'Просмотр забега', admin_activity_path(params[:activity_id])
  end
end
