# frozen_string_literal: true

ActiveAdmin.register Result do
  # belongs_to :activity, optional: true
  includes :athlete, activity: :event

  actions :all, except: :new

  permit_params :total_time, :position, :athlete_id

  index download_links: false do
    selectable_column
    column :position
    column :athlete
    column('Результат') { |r| human_result_time(r.total_time) }
    column('Забег') { |r| human_activity_name(r.activity) }
    column :user
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
end
