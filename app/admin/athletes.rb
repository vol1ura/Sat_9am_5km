# frozen_string_literal: true

ActiveAdmin.register Athlete do
  # actions :all, except: :destroy
  includes :user
  permit_params :parkrun_code, :fiveverst_code, :name, :male, :user_id, :club_id

  index download_links: false do
    selectable_column
    column :name
    column :parkrun_code
    column :fiveverst_code
    column :gender
    column :user
    actions
  end

  show do
    attributes_table do
      row :parkrun_code
      row :fiveverst_code
      row :gender
      row :club
      row :user
    end
  end

  form do |f|
    f.semantic_errors
    f.hidden_field :result_id, value: params[:result_id] if params[:result_id].present?
    f.inputs do
      f.input :name
      f.input :parkrun_code
      f.input :fiveverst_code
      f.input :club
      f.input :male, as: :radio, collection: [['мужчина', true], ['женщина', false]], include_blank: false, label: 'Пол'
    end
    f.actions
  end

  after_create do |athlete|
    result_id = params[:athlete][:result_id]
    if result_id.present?
      athlete.results << Result.find(result_id)
      athlete.save!
    end
  end
end
