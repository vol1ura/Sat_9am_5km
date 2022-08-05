# frozen_string_literal: true

ActiveAdmin.register Club do
  permit_params :name

  filter :name

  index download_links: false
end
