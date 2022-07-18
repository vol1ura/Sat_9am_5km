# frozen_string_literal: true

ActiveAdmin.register Trophy do
  belongs_to :badge

  permit_params :badge_id, :athlete_id, :date

  config.filters = false
end
