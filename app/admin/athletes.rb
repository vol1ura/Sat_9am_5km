# frozen_string_literal: true

ActiveAdmin.register Athlete do
  config.comments = false
  actions :all, except: :destroy
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :parkrun_code, :fiveverst_code, :name, :male, :user_id, :club_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:parkrun_code, :fiveverst_code, :first_name, :last_name, :male, :user_id, :club_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index download_links: false do
    selectable_column
    column :name
    column :parkrun_code
    column :fiveverst_code
    column :gender
    column :user
    actions
  end

  # f.input :male, label: 'Мужчина'
  # f.input :parkrun_id, label: 'Паркрановский номер'
end
