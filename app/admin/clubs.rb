# frozen_string_literal: true

ActiveAdmin.register Club do
  includes :country
  permit_params :name, :country_id

  actions :all, except: :show

  filter :name
  filter :country

  index download_links: false
end
