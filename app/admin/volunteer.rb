# frozen_string_literal: true

ActiveAdmin.register Volunteer do
  config.comments = false

  permit_params :role, :activity_id, :athlete_id
end
