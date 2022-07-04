# frozen_string_literal: true

ActiveAdmin.register Athlete do
  includes :user
  permit_params :parkrun_code, :fiveverst_code, :name, :male, :user_id, :club_id

  filter :club
  filter :name
  filter :parkrun_code
  filter :fiveverst_code
  filter :male
  filter :created_at
  filter :updated_at

  index download_links: false do
    selectable_column
    column :name
    column :parkrun_code
    column :fiveverst_code
    column :gender
    column :user
    actions
  end

  show { render athlete }

  form partial: 'form'

  after_create do |athlete|
    result_id = params[:athlete][:result_id]
    if result_id.present?
      athlete.results << Result.find(result_id)
      athlete.save!
    end
  end
end
