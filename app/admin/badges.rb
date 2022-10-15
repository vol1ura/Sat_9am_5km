# frozen_string_literal: true

ActiveAdmin.register Badge do
  actions :all, except: :destroy

  permit_params :name, :conditions, :received_date, :picture_link

  filter :name
  filter :conditions
  filter :received_date

  index download_links: false do
    selectable_column
    column :name
    column :received_date
    column :conditions
    column :picture_link
    actions
  end

  show do
    attributes_table do
      row :name
      row :received_date
      row :conditions
      row :picture_link
    end
  end

  sidebar 'Управление наградой', only: :show do
    ul do
      li link_to 'Обладатели', admin_badge_trophies_path(resource)
    end
    h3 'Предпросмотр'
    image_tag resource.picture_link, class: 'img-badge'
  end
end
