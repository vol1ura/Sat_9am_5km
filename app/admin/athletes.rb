# frozen_string_literal: true

ActiveAdmin.register Athlete do
  includes :club, :event
  batch_action :destroy, false
  permit_params :parkrun_code, :fiveverst_code, :runpark_code, :name, :male, :user_id, :club_id, :event_id

  config.per_page = [20, 50, 100]

  scope :all
  scope(:duplicates) { |s| s.where(id: Athletes::DuplicatesFinder.call) }

  filter :name
  filter :id
  filter :parkrun_code
  filter :fiveverst_code
  filter :runpark_code
  filter(
    :male,
    as: :select,
    label: I18n.t('common.gender'),
    collection: { I18n.t('common.man') => true, I18n.t('common.woman') => false },
  )
  filter :club, as: :searchable_select
  filter :event, as: :searchable_select
  filter :going_to_event, as: :searchable_select
  filter :created_at
  filter :updated_at

  index download_links: false do
    selectable_column
    column :name
    id_column
    column :parkrun_code
    column :fiveverst_code
    column :runpark_code
    column :gender
    column :club
    column :event
    column(:registered) { |a| a.user_id.present? }
    actions
  end

  show { render athlete }

  form partial: 'form'

  sidebar 'Фото', only: %i[show edit], if: proc { resource.user&.image&.attached? } do
    image_tag resource.user.image.variant(:web), class: 'img-badge'
  end

  before_create do |athlete|
    result_id = params.dig(:athlete, :result_id)
    athlete.results << Result.find(result_id) if result_id
  end

  controller do
    def destroy
      if resource.user_id
        flash[:error] = t '.cannot_delete_registered'
      elsif resource.results.exists? || Volunteer.exists?(athlete: resource)
        flash[:error] = t '.cannot_delete_participant'
      else
        flash[:notice] = t '.successfully_deleted', obj: resource.name
        return super
      end

      redirect_to resource_path
    end
  end

  batch_action :reunite, confirm: I18n.t('active_admin.athletes.confirm_reunite'),
                         if: proc { can? :manage, Athlete } do |ids|
    if Athletes::Reuniter.call(batch_action_collection.where(id: ids), ids)
      flash[:notice] = I18n.t('active_admin.athletes.successful_reunite')
    else
      flash[:error] = I18n.t('active_admin.athletes.failed_reunite')
    end
    redirect_to collection_path(scope: :duplicates)
  end

  batch_action :gender_set, confirm: I18n.t('active_admin.athletes.confirm_gender_set'),
                            if: proc { can? :manage, Athlete },
                            form: { gender: %w[мужчина женщина] } do |ids, inputs|
    batch_action_collection.where(id: ids).update_all male: inputs[:gender] == 'мужчина'
    redirect_to collection_path, notice: I18n.t('active_admin.athletes.successful_gender_set')
  end

  member_action :results, method: :get do
    @results = resource.results.includes(activity: :event).order('activity.date DESC')
    @page_title = t '.title'
  end

  member_action :volunteering, method: :get do
    @volunteering = resource.volunteering.includes(activity: :event)
    @page_title = t '.title'
  end

  member_action :trophies, method: :get do
    @trophies = resource.trophies.includes(:badge).order(created_at: :desc)
    @page_title = t '.title'
  end
end
