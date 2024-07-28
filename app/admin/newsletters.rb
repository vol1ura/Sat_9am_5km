# frozen_string_literal: true

ActiveAdmin.register Newsletter do
  permit_params :body, :picture_link

  config.filters = false
  config.sort_order = 'created_at_desc'

  index download_links: false do
    selectable_column
    id_column
    column(:body) { |nl| simple_format nl.body }
    column(:picture_link) { |nl| nl.picture_link.present? }
    actions
  end

  show do
    attributes_table do
      row :picture_link
      row(:body) { |nl| simple_format nl.body }
      row :updated_at
      row :created_at
    end
  end

  member_action :notify, method: :get do
    Telegram::Notification::Newsletter.call(resource, current_user)
    redirect_to admin_newsletter_path(resource), notice: I18n.t('active_admin.newsletters.notified')
  end

  action_item :notify, only: :show do
    link_to 'Отправить себе', notify_admin_newsletter_path(resource)
  end

  sidebar :markdown_help, only: %i[show edit] do
    para 'Для выделения текста используйте следующие символы:'
    ul do
      li '*жирный текст*'
      li '_наклонный текст_'
      li '[ссылка](http://www.example.com/)'
      li '`моноширный текст`'
    end
    para a('Подробнее', href: 'https://core.telegram.org/bots/api#markdown-style', target: '_blank')
  end
end
