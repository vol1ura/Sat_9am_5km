# frozen_string_literal: true

ActiveAdmin.register TeamMember do
  menu priority: 110
  includes :athlete, :country

  permit_params :athlete_id, :country_id, :rank, :photo, role_translations: I18n.available_locales

  config.sort_order = 'rank_asc'

  filter :country

  index download_links: false do
    selectable_column
    column :rank
    column(:athlete, sortable: false) { |m| link_to m.name, m.athlete }
    column :country
    column :role, sortable: false
    actions
  end

  show do
    attributes_table do
      row :rank
      row(:athlete) { |m| link_to m.name, m.athlete }
      row :country
      I18n.available_locales.each do |locale|
        row("#{TeamMember.human_attribute_name(:role)} (#{locale})") { |m| m.role_translations[locale.to_s] }
      end
      row :created_at
      row :updated_at
      row(:photo) { |m| image_tag m.photo.variant(:web), alt: m.name }
    end
  end

  form partial: 'form'
end
