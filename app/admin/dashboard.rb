# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { t 'active_admin.dashboard' }

  content title: proc { t 'active_admin.dashboard' } do
    columns do
      column do
        panel t('active_admin.dashboard_welcome.upcoming_activities') do
          ul do
            Activity
              .unpublished
              .in_country(top_level_domain)
              .includes(:event)
              .where(date: Date.current..Date.tomorrow.end_of_week)
              .order(:date, :visible_order)
              .each do |activity|
                li link_to_if(can?(:read, activity), human_activity_name(activity), admin_activity_path(activity))
              end
          end
        end

        panel t('active_admin.dashboard_welcome.latest_activities') do
          ul do
            Activity
              .in_country(top_level_domain)
              .includes(:event)
              .order(created_at: :desc)
              .first(10)
              .each do |activity|
                li link_to_if(can?(:read, activity), human_activity_name(activity), admin_activity_path(activity))
              end
          end
        end
      end
      column do
        panel t('active_admin.dashboard_welcome.info') do
          para t 'active_admin.dashboard_welcome.call_to_action'
        end
        panel t('active_admin.dashboard_welcome.change_log') do
       
        end
      end
    end
  end
end
