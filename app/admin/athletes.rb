# frozen_string_literal: true

ActiveAdmin.register Athlete do
  includes :user, :club
  permit_params :parkrun_code, :fiveverst_code, :name, :male, :user_id, :club_id

  filter :name
  filter :parkrun_code
  filter :fiveverst_code
  filter :male
  filter :club
  filter :created_at
  filter :updated_at

  index download_links: false do
    selectable_column
    column :name
    column :parkrun_code
    column :fiveverst_code
    column :gender
    column :club
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

  batch_action :join, confirm: I18n.t('active_admin.athletes.confirm_join'),
                      form: { gender: %w[мужчина женщина] } do |ids, inputs|
    collection = batch_action_collection.where(id: ids)
    athlete = collection.where.not(name: nil).take
    if athlete
      athlete.parkrun_code ||= collection.where.not(parkrun_code: nil).take&.parkrun_code
      athlete.fiveverst_code ||= collection.where.not(fiveverst_code: nil).take&.fiveverst_code
      athlete.user_id ||= collection.where.not(user_id: nil).take&.user_id
      athlete.male = inputs[:gender] == 'мужчина'
      athlete.save!
      Result.where(athlete_id: ids).update_all(athlete_id: athlete.id) # rubocop:disable Rails/SkipsModelValidations
      Volunteer.where(athlete_id: ids).update_all(athlete_id: athlete.id) # rubocop:disable Rails/SkipsModelValidations
      collection.where.not(id: athlete.id).destroy_all
      redirect_to collection_path, notice: I18n.t('active_admin.athletes.successful_join')
    else
      redirect_to collection_path, alert: I18n.t('active_admin.athletes.failed_join')
    end
  end

  batch_action :gender_set, confirm: I18n.t('active_admin.athletes.confirm_gender_set'),
                            form: { gender: %w[мужчина женщина] } do |ids, inputs|
    collection = batch_action_collection.where(id: ids)
    collection.update_all(male: inputs[:gender] == 'мужчина') # rubocop:disable Rails/SkipsModelValidations
    redirect_to collection_path, notice: I18n.t('active_admin.athletes.successful_gender_set')
  end
end
