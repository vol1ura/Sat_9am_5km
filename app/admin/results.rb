# frozen_string_literal: true

ActiveAdmin.register Result do
  # belongs_to :activity, optional: true
  includes :activity, :athlete

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
    if params[:parkrun_code].present?
      athlete = Athlete.find_by parkrun_code: params[:parkrun_code].to_s.strip
      if athlete
        result.athlete = athlete
      else
        flash[:alert] = "Участник с parkrun id='#{params[:parkrun_code]}' не найден. \
        # Проверьте номер или сначала создайте такого участника."
      end
    end
  end
end
