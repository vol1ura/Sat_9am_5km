# frozen_string_literal: true

ActiveAdmin.register VolunteerApplication do
  belongs_to :activity

  actions :all, except: %i[new edit create update show]

  includes :athlete

  config.sort_order = 'created_at_asc'
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
  end

  member_action :approve, method: :put do
    resource.approve!
    redirect_to collection_path, notice: t('.approved')
  rescue ActiveRecord::RecordInvalid => e
    redirect_to collection_path, alert: e.message
  end

  member_action :reject, method: :put do
    resource.reject!
    redirect_to collection_path, notice: t('.rejected')
  end

  index title: -> { t '.title', date: l(@activity.date) } do
    column :athlete
    column(:role) { |a| human_volunteer_role a.role }
    column(:status) { |a| t("activerecord.attributes.volunteer_application.statuses.#{a.status}") }
    column :created_at
    actions do |application|
      if application.pending?
        item t('admin.volunteer_applications.index.approve'),
             approve_admin_activity_volunteer_application_path(application.activity, application),
             method: :put, class: 'member_link'
        item t('admin.volunteer_applications.index.reject'),
             reject_admin_activity_volunteer_application_path(application.activity, application),
             method: :put, class: 'member_link'
      end
    end
  end

  action_item :activity, only: :index do
    link_to 'Просмотр забега', admin_activity_path(activity.id)
  end

  action_item :volunteers, only: :index do
    link_to 'Волонтёры', admin_activity_volunteers_path(activity)
  end
end
