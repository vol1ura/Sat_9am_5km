# frozen_string_literal: true

ActiveAdmin.register Volunteer do
  belongs_to :activity

  includes :athlete, activity: :event

  permit_params :role, :activity_id, :athlete_id

  config.sort_order = 'id_asc'
  config.filters = false
  config.paginate = false

  controller do
    def scoped_collection
      if current_user.admin?
        end_of_association_chain
      else
        event_ids = current_user.permissions.where(subject_class: 'Volunteer').pluck(:event_id).compact
        end_of_association_chain.joins(:activity).where(activity: { event_id: event_ids })
      end
    end

    def update
      update! do |format|
        if resource.valid?
          format.html { redirect_to collection_path, notice: t('active_admin.volunteers.successful_updated') }
        end
      end
    end

    def create
      create! do |format|
        if resource.valid?
          format.html { redirect_to collection_path, notice: t('active_admin.volunteers.successful_created') }
        end
      end
    end
  end

  index download_links: [:csv], title: -> { "Редактор волонтёров #{@activity.date ? l(@activity.date) : '(нет даты)'}" } do
    selectable_column
    column :athlete
    column(:role) { |v| human_volunteer_role v.role }
    column(:activity) { |v| human_activity_name v.activity }
    actions
  end

  csv do
    column(:code) { |v| v.athlete.code }
    column(:athlete, &:name)
    column(:role) { |v| human_volunteer_role v.role }
  end

  show(title: :name) { render volunteer }

  form partial: 'form'

  action_item :activity, only: :index do
    link_to 'Просмотр забега', admin_activity_path(params[:activity_id])
  end

  action_item :volunteering_positions, only: :index, if: proc { current_user.volunteering_position_permission } do
    link_to 'Настройка позиций',
            admin_event_volunteering_positions_path(current_user.volunteering_position_permission.event)
  end
end
