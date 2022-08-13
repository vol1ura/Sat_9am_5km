# frozen_string_literal: true

ActiveAdmin.register Volunteer do
  includes :athlete, activity: :event

  permit_params :role, :activity_id, :athlete_id

  controller do
    def scoped_collection
      if current_user.admin?
        end_of_association_chain
      else
        event_ids = current_user.permissions.where(subject_class: 'Volunteer').pluck(:event_id).compact
        end_of_association_chain.joins(:activity).where(activity: { event_id: event_ids })
      end
    end
  end

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
