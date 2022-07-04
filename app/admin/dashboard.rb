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
            Activity.published.includes(:event).order(:created_at).last(10).map do |activity|
              li link_to(human_activity_name(activity), admin_activity_path(activity))
            end
          end
        end
      end

      column do
        panel 'Информация' do
          para 'Добро пожаловать.'
          para 'Сюда добавить инфу для новых руководителей забегов по тому, как пользоваться системой.'
        end
      end
    end
  end
end
