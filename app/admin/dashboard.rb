# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { t 'active_admin.dashboard' }

  content title: proc { t 'active_admin.dashboard' } do
    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        span t 'active_admin.dashboard_welcome.welcome'
        small t 'active_admin.dashboard_welcome.notification'
      end
    end

    columns do
      column do
        panel t('active_admin.dashboard_welcome.info') do
          para t 'active_admin.dashboard_welcome.call_to_action'
        end
      end
      column do
        panel t('active_admin.dashboard_welcome.latest_activities') do
          ul do
            Activity.includes(:event).order(created_at: :desc).limit(10).map do |activity|
              li link_to(human_activity_name(activity), admin_activity_path(activity))
            end
          end
        end
      end
    end
  end
end
