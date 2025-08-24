# frozen_string_literal: true

ActiveAdmin.register Volunteer do
  belongs_to :activity

  actions :all, except: :show

  includes :athlete

  permit_params :role, :activity_id, :athlete_id, :comment

  config.sort_order = 'role_asc'
  config.filters = false
  config.paginate = false

  controller do
    def scoped_collection
      if current_user.admin?
        end_of_association_chain
      else
        event_ids = current_user.permissions.where(subject_class: 'Volunteer').select(:event_id).distinct
        end_of_association_chain.joins(:activity).where(activity: { event_id: event_ids })
      end
    end

    def update
      update!(notice: t('.successful', volunteer_name: resource.name)) { collection_path }
    end

    def create
      create!(notice: t('.successful')) { collection_path }
    end
  end

  after_save { |volunteer| volunteer.activity.postprocessing }

  index download_links: [:csv], title: -> { t '.title', date: l(@activity.date) } do
    selectable_column
    column :athlete
    column(:role) { |v| human_volunteer_role v.role }
    column :comment
    actions
  end

  csv do
    column(:role) { |v| human_volunteer_role v.role }
    column :name
    column(:code) { |v| v.athlete.code }
  end

  form partial: 'form'

  action_item :activity, only: :index do
    link_to 'Просмотр забега', admin_activity_path(activity.id)
  end

  action_item(
    :volunteering_positions,
    only: :index,
    if: proc do
      current_user.admin? ||
        current_user
          .permissions
          .exists?(event_id: activity.event_id, subject_class: 'VolunteeringPosition', action: %w[manage update])
    end,
  ) { link_to 'Настройка позиций', admin_event_volunteering_positions_path(activity.event) }
end
