# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        span I18n.t('active_admin.dashboard_welcome.welcome')
        small I18n.t('active_admin.dashboard_welcome.call_to_action')
      end
    end

    columns do
      column do
        panel 'Недавние забеги' do
          ul do
            Activity.order(created_at: :desc).first(5).map do |activity|
              li link_to("#{activity.date} - #{activity.event.code_name}", admin_activity_path(activity))
            end
          end
        end
      end

      column do
        panel 'Информация' do
          para 'Добро пожаловать.'
        end
      end
    end
  end
end
