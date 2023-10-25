# frozen_string_literal: true

ActiveAdmin.register Event do
  menu priority: 2
  actions :all, except: :destroy

  config.sort_order = 'visible_order_asc'

  permit_params(
    :description, :active, :place, :name, :main_picture_link, :code_name, :town, :visible_order, :slogan, :country_code
  )

  filter :country_code, as: :select, collection: Event.country_codes
  filter :code_name
  filter :name
  filter :town
  filter :place

  scope :all
  scope(:active) { |s| s.where(active: true) }
  scope(:inactive) { |s| s.where(active: false) }

  index download_links: false do
    column :visible_order
    column :active
    column :country_code
    column :code_name
    column :name
    column :town
    column :place
    column :slogan
    actions
  end

  show do
    attributes_table do
      row :active
      row :country_code
      row :code_name
      row :name
      row :town
      row :place
      row :main_picture_link
      row :slogan
      row :visible_order
      row(:description) { |e| sanitized_text e.description }
      row :updated_at
      row :created_at
    end
  end

  form partial: 'form'

  sidebar 'Инструкция', only: %i[new edit] do
    li 'Кодовое имя должно состоять из маленьких латинских букв, можно использовать символ "_". Для паркрановских локаций
    крайне желательно использовать то же самое имя, что было. Например, angarskieprudy - Ангарские Пруды.'
    li 'В поле Местонахождение должно быть описание как найти мероприятие. Этот текст появится в блоке Как нас найти?
    на странице мероприятия. Желательно добавить 2-4 предложения.'
    li 'Ссылка на баннер может быть как в виде url на внешнюю картинку, так и в виде указания относительного пути в ассетах.
    Крайне желательно использовать формат jpg и привести к размеру 1280х482 пикселя.'
    li 'В поле Девиз прописывается короткое ёмкое описание мероприятия, которое будет отображаться на главной странице.'
    li 'Вес в ленте - числовое значение, чем оно больше, тем ниже событие будет расположено в ленте на главной странице.'
  end

  sidebar 'Настройки', only: %i[show edit] do
    ul do
      li link_to 'Контакты', admin_event_contacts_path(resource)
      li link_to 'Волонтёры', admin_event_volunteering_positions_path(resource)
    end
  end

  sidebar 'Предпросмотр', only: :show do
    image_tag resource.main_picture_link, class: 'img-badge' if resource.main_picture_link
  end
end
