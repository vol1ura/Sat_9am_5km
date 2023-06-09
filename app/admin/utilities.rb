# frozen_string_literal: true

ActiveAdmin.register_page 'Utilities' do
  menu priority: 100, label: proc { t 'active_admin.utilities' }

  content title: proc { t '.utilities' } do
    tabs do
      tab t('.cache_clear.title') do
        para "Кеш можно сбрасывать не чаще, чем раз в #{ClearCache::TIME_THRESHOLD.in_minutes.ceil} минут."
        para button_to t('.cache_clear.button'),
                       admin_utilities_clear_cache_path,
                       method: :delete,
                       data: { confirm: t('.cache_clear.confirm') }
      end

      tab t('.badges.title') do
        panel 'Установка фан-ран бейджа' do
          para 'Внимание! Будут награждены все участники и волонтёры выбранного забега.'
          render partial: 'funrun_badge_awarding_form'
        end
      end
    end
  end

  page_action :award_funrun_badge, method: :post do
    FunrunAwardingJob.perform_later(params[:activity_id], params[:badge_id])
    redirect_to admin_badge_trophies_path(params[:badge_id]), notice: t('.performing')
  end

  page_action :clear_cache, method: :delete do
    if ClearCache.call
      flash[:notice] = t('.success')
    else
      flash[:alert] = t('.failed')
    end
    redirect_to admin_utilities_path
  end
end
