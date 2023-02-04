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
        panel t('active_admin.dashboard_welcome.change_log') do
          ul do
            li 'На форму создания результата добавлено поле с автокомплитом для поиска участников.'
            li 'После публикации забега в Деталях появляется ссылка на протокол данного забега на сайте.'
            li 'Возможность создавать свой набор волонтёрских позиций под каждую локацию.'
            li 'Оптимизация запросов, тонкая настройка меню и системы.'
            li 'Действие Удалить в редакторе протокола корректно удаляет результат, пересчитывая позиции.'
            li 'В редактор волонтёров добавлена возможность выгрузить таблицу в CSV файл.'
            li 'Награды участникам присваиваются в фоновом режиме после публикации протокола, если заполнены волонтёры.'
            li 'В редакторе протокола теперь можно вставить новый результат (строку) в любом месте. Наконец-то )'
            li 'Можно устанавливать пол новым участникам сразу при просмотре протокола.'
            li 'В поле для описания забега встроен редактор текста. Можно форматировать текст, добавлять ссылки на альбомы'
            li 'Автоматическое удаление лишних пробелов в имени участника'
            li 'После добавления волонтёра в забег происходит редирект на список волонтёров, а не на новую запись'
            li 'На страницу забега добавлена ссылка на внешний ресурс (паркран или 5 вёрст), можно посмотреть имя участника'
            li 'Поиск дубликатов переехал в фильтры и теперь ищет в любом порядке'
            li 'В разделе Участники можно выбрать сколько строк выводить на странице'
            li 'Расширен функционал редактора протокола за счёт переноса функций со странички просмотра забега.'
            li 'Изменена форма редактирования результата. Можно вводить как parkrun, 5 вёрст id, так и id из базы сайта.'
            li <<~CHANGE
              Добавлен автокомлит на страницу "Расписание волонтёров" (например,
              #{volunteering_event_url(Event.first.code_name)}). Чтобы воспользоваться инструментом,
              предварительно нужно создать пустой предстоящий забег (можно сразу на 4 недели вперёд).
            CHANGE
            li 'Увеличен размер шрифтов.'
            li 'Раздел "Волонтёры" перенесён в "Забеги" и доступен из каждого забега по кнопке "Редактор волонтёров".'
            li 'Изменён диалог добавления волонтёрства. Выбор участника может производиться из автокомплита по имени и шк.'
          end
        end
      end
      column do
        panel t('active_admin.dashboard_welcome.latest_activities') do
          ul do
            Activity.includes(:event).order(created_at: :desc).limit(10).map do |activity|
              li link_to_if(can?(:read, activity), human_activity_name(activity), admin_activity_path(activity))
            end
          end
        end
      end
    end
  end
end
