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

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      # f.input :athlete_name
      # f.input :athlete_parkrun_code
      f.input :position
    end
    f.actions
  end
end
