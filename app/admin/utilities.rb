# frozen_string_literal: true

ActiveAdmin.register_page 'Utilities' do
  menu priority: 100, label: proc { t 'active_admin.utilities' }

  content title: proc { t '.utilities' } do
    tabs do
      tab 'Отчёты' do
        panel 'Выгрузка данных по выбранному мероприятию' do
          para 'Будет сформирован CSV файл с отчётом по всем результатам и волонтёрствам на выбранном мероприятии.'
          render partial: 'event_csv_export_form'
        end
      end

      tab t('.badges.title') do
        panel 'Установка фан-ран бейджа' do
          para 'Внимание! Будут награждены все участники и волонтёры выбранного забега.'
          render partial: 'funrun_badge_awarding_form'
        end
      end

      tab t('.analytics.title') do
        stats_for = lambda do |model|
          Activity
            .published
            .where(date: 12.months.ago.beginning_of_month..Date.current.end_of_month)
            .joins(model)
            .group("DATE_TRUNC('month', activities.date)")
            .order(month: :desc)
            .select(
              "DATE_TRUNC('month', activities.date) AS month,
              COUNT(DISTINCT activities.id) AS activities_count,
              COUNT(#{model}.id) AS total_count,
              ROUND(COUNT(#{model}.id)::numeric / COUNT(DISTINCT activities.id), 1) AS avg_count",
            )
        end

        panel t('.analytics.volunteers.title') do
          table do
            thead do
              tr do
                th t('.analytics.month')
                th t('.analytics.activities_count')
                th t('.analytics.volunteers.count')
                th t('.analytics.volunteers.avg_count')
              end
            end
            tbody do
              stats_for.call(:volunteers).each do |stat|
                tr do
                  td do
                    month_date = stat.month.to_date
                    "#{I18n.t('date.month_names')[month_date.month]} #{month_date.year}"
                  end
                  td stat.activities_count
                  td stat.total_count
                  td stat.avg_count
                end
              end
            end
          end
        end

        panel t('.analytics.results.title') do
          table do
            thead do
              tr do
                th t('.analytics.month')
                th t('.analytics.activities_count')
                th t('.analytics.results.count')
                th t('.analytics.results.avg_count')
              end
            end
            tbody do
              stats_for.call(:results).each do |stat|
                tr do
                  td do
                    month_date = stat.month.to_date
                    "#{I18n.t('date.month_names')[month_date.month]} #{month_date.year}"
                  end
                  td stat.activities_count
                  td stat.total_count
                  td stat.avg_count
                end
              end
            end
          end
        end
      end

      tab t('.cache_clear.title') do
        para "Кеш можно сбрасывать не чаще, чем раз в #{ClearCache::TIME_THRESHOLD.in_minutes.ceil} минут."
        table do
          tr do
            th 'Metric'
            th 'Value'
          end
          stats = defined?(Rails.cache.stats) ? Rails.cache.stats.first.last : {}
          tr do
            td 'Connections:'
            td stats['curr_connections']
          end
          tr do
            td 'Cache hits:'
            td stats['get_hits']
          end
          tr do
            td 'Cache misses:'
            td stats['get_misses']
          end
          tr do
            td 'Cache flushes:'
            td stats['cmd_flush']
          end
          tr do
            td 'Memory:'
            td "#{(stats['bytes_read'].to_f / 1.megabyte).round} Mb"
          end
        end
        para button_to t('.cache_clear.button'),
                       admin_utilities_cache_path,
                       method: :delete,
                       data: { confirm: t('.cache_clear.confirm') }
      end
    end
  end

  page_action :award_funrun_badge, method: :post do
    job_args = params.values_at(:activity_id, :badge_id)
    FunrunAwardingJob.perform_later(*job_args)
    FunrunAwardingJob.set(wait: 12.hours).perform_later(*job_args)
    redirect_to admin_badge_trophies_path(params[:badge_id]), notice: t('.performing')
  end

  page_action :cache, method: :delete do
    if ClearCache.call
      flash[:notice] = t('.clear_success')
    else
      flash[:alert] = t('.clear_failed')
    end
    redirect_to admin_utilities_path
  end

  page_action :export_event_csv, method: :post do
    if (event_id = params[:event_id]).present?
      EventAthletesCsvExportJob.perform_later(event_id.to_i, current_user.id)
      flash[:notice] = t '.reports.task_queued'
    else
      flash[:alert] = t '.reports.event_not_selected'
    end
    redirect_to admin_utilities_path
  end
end
