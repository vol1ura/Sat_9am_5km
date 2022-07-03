# frozen_string_literal: true

ActiveAdmin.register Result do
  # belongs_to :activity, optional: true
  includes :activity, :athlete

  # actions :all, except: :destroy
  permit_params :total_time, :position, :athlete_id

  # menu priority: 2
  # filter :date

  index download_links: false do
    selectable_column
    column :position
    column :athlete
    column('Результат') { |r| human_result_time(r.total_time) }
    column('Забег') { |r| "#{r.activity.event.name} #{r.activity.date.to_s(:long)}" }
    column :user
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      # f.input :athlete_name
      # f.input :athlete_parkrun_code
      f.input :position
    end
    f.actions
  end
end
