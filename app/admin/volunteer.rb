# frozen_string_literal: true

ActiveAdmin.register Volunteer do
  includes :athlete, activity: :event

  permit_params :role, :activity_id, :athlete_id

  filter :role, as: :select, collection: Volunteer::ROLES

  index download_links: false do
    selectable_column
    column :athlete
    column('Забег') { |v| human_activity_name v.activity }
    column('Роль') { |v| human_volunteer_role v.role }
    actions
  end

  show(title: :name) { render volunteer }

  form partial: 'form'

  before_create do |volunteer|
    athlete = Athlete.find_by parkrun_code: params[:parkrun_code].to_s.strip
    volunteer.athlete = athlete if athlete
  end
end
