# frozen_string_literal: true

ActiveAdmin.register Club do
  includes :country, logo_attachment: :blob

  permit_params :name, :country_id, :logo, :description

  actions :all, except: :show

  filter :name
  filter :country

  index download_links: false do
    selectable_column
    id_column
    column(:logo) { |c| image_tag c.logo.variant(:thumb) if c.logo.attached? }
    column :name
    column(:description) { |c| sanitized_text c.description&.truncate(160) }
    column :country
    actions
  end

  form partial: 'form'
end
