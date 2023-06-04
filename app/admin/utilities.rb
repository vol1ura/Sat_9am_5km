# frozen_string_literal: true

ActiveAdmin.register_page 'Utilities' do
  menu priority: 100, label: proc { t 'active_admin.utilities.title' }

  content title: proc { t 'active_admin.utilities.title' } do
    columns do
      column do
        panel 'Установка фан-ран бейджа' do
          para 'Внимание! Будут награждены все участники и волонтёры выбранного забега.'
          render partial: 'funrun_badge_awarding_form'
        end
      end
      column do
        panel 'Что-то ещё' do
          para ''
        end
      end
    end
  end

  page_action :award_funrun_badge, method: :post do
    FunrunAwardingJob.perform_later(params[:activity_id], params[:badge_id])
    redirect_to admin_badge_trophies_path(params[:badge_id]), notice: t('active_admin.utilities.funrun_awarding_performing')
  end
end
