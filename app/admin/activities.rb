# frozen_string_literal: true

ActiveAdmin.register Activity do
  includes :event

  permit_params :description, :published, :event_id

  menu priority: 3

  filter :date
  filter :event, label: 'Забег'

  scope :all
  scope :published
  scope :unpublished

  index download_links: false do
    column :date
    column('Где?') { |a| a.event.name }
    column :published
    actions
  end

  show { render activity }

  form title: 'Загрузка забега', multipart: true, partial: 'form'

  sidebar 'Редактирование протокола', only: :show do
    li 'Если участник отобразился как "НЕИЗВЕСТНЫЙ", значит не удалось автоматически заполнить его имя.
    Кликните по НЕИЗВЕСТНЫЙ и воспользуйтесь сайтом parkrun или 5вёрст чтобы по ID найти имя.'
    li 'Если участник отобразился как "БЕЗ ТОКЕНА (создать)", значит он не отсканировался. Возможно, этот человек
    уже есть в базе и создавать новую запись НЕ НУЖНО - кликните по результату и в открывшейся форме введите parkrun ID.'
  end

  after_create do |activity|
    TimerParser.call(activity, params[:activity][:timer])
    Activity::MAX_SCANNERS.times do |scanner_number|
      ScannerParser.call(activity, params[:activity]["scanner#{scanner_number}".to_sym])
    end
  end
end
