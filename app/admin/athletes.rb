# frozen_string_literal: true

ActiveAdmin.register Athlete do
  includes :user, :club

  permit_params :parkrun_code, :fiveverst_code, :name, :male, :user_id, :club_id

  config.per_page = [20, 50, 100]

  scope :all, default: true
  scope :duplicates

  filter :name
  filter :id
  filter :parkrun_code
  filter :fiveverst_code
  filter :male
  filter :club
  filter :created_at
  filter :updated_at

  index download_links: false do
    selectable_column
    column :name
    column :id
    column :parkrun_code
    column :fiveverst_code
    column :gender
    column :club
    column :user
    actions
  end

  show { render athlete }

  form partial: 'form'

  before_create do |athlete|
    result_id = params.dig(:athlete, :result_id)
    athlete.results << Result.find(result_id) if result_id
  end

  batch_action :reunite, confirm: I18n.t('active_admin.athletes.confirm_reunite'),
                         if: proc { can? :manage, Athlete } do |ids|
    collection = batch_action_collection.where(id: ids)
    if AthleteReuniter.call(collection, ids)
      redirect_to collection_path(scope: :duplicates), notice: I18n.t('active_admin.athletes.successful_reunite')
    else
      redirect_to collection_path, alert: I18n.t('active_admin.athletes.failed_reunite')
    end
  end

  batch_action :gender_set, confirm: I18n.t('active_admin.athletes.confirm_gender_set'),
                            if: proc { can? :manage, Athlete },
                            form: { gender: %w[мужчина женщина] } do |ids, inputs|
    collection = batch_action_collection.where(id: ids)
    collection.update_all(male: inputs[:gender] == 'мужчина') # rubocop:disable Rails/SkipsModelValidations
    redirect_to collection_path, notice: I18n.t('active_admin.athletes.successful_gender_set')
  end
end
