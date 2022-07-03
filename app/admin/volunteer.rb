# frozen_string_literal: true

ActiveAdmin.register Volunteer do
  permit_params :role, :activity_id, :athlete_id
end
