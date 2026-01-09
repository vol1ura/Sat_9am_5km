# frozen_string_literal: true

ActiveAdmin.register Event do
  includes :country

  menu priority: 90
  actions :all, except: :destroy

  config.sort_order = 'visible_order_asc'

  permit_params(
    :description, :active, :place, :name, :summer_image, :winter_image, :code_name,
    :town, :visible_order, :country_id, :latitude, :longitude, :timezone,
  )

  filter :country
  filter :code_name
  filter :name
  filter :town

  scope :all
  scope :active
  scope(:inactive) { |s| s.where(active: false) }

  index download_links: false do
    column :visible_order
    column :active
    column :country
    column :code_name
    column :name
    column :town
    column :place
    actions
  end

  show do
    attributes_table do
      row :active
      row :country
      row :code_name
      row :name
      row :town
      row :place
      row(:coordinates) { |e| "#{e.latitude},#{e.longitude}" }
      row :timezone
      row :visible_order
      row(:description) { |e| sanitized_text e.description }
      row :updated_at
      row :created_at
    end
  end

  form partial: 'form'

  sidebar 'Инструкция', only: %i[new edit] do
    li 'Кодовое имя должно состоять из маленьких латинских букв, можно использовать символ "_".
    Например, angarskie_prudy - Ангарские Пруды.'
    li 'В поле Местонахождение должно быть описание как найти мероприятие. Этот текст появится в блоке Как нас найти?
    на странице мероприятия. Желательно добавить 2-4 предложения.'
    li 'Изображения должны быть в формате jpg, png или webp (предпочтительно webp)
    размером не менее 2800х1060 пикселей и весом не менее 150 Кб (в идеале ~400 Кб), но не более 5 Мб.
    Если зимнее изображение не загружено, то всё время будет отображаться летнее изображение.'
    li 'Вес в ленте - числовое значение, чем оно больше, тем ниже событие будет расположено в ленте на главной странице.'
  end

  sidebar 'Настройки', only: %i[show edit] do
    ul do
      li link_to 'Контакты', admin_event_contacts_path(resource)
      li link_to 'Волонтёры', admin_event_volunteering_positions_path(resource)
    end
  end

  sidebar 'Летнее изображение', only: :show, if: proc { resource.summer_image.attached? } do
    image_tag resource.summer_image.variant(:thumb), class: 'img-badge', alt: resource.place
  end

  sidebar 'Зимнее изображение', only: :show, if: proc { resource.winter_image.attached? } do
    image_tag resource.winter_image.variant(:thumb), class: 'img-badge', alt: resource.place
  end

  action_item :analytics, only: :show, if: proc { can? :read, Event, id: resource.id } do
    link_to t('admin.events.analytics.title'), analytics_admin_event_path(resource)
  end

  member_action :analytics, method: :get, if: proc { can? :read, Event, id: resource.id } do
    @page_title = t '.title'
  end
end
