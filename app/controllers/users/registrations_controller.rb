# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def new
      build_resource({})
      resource.build_athlete
      respond_with resource
    end

    def create
      build_resource(sign_up_params)
      resource.password = SecureRandom.hex(16)
      resource.build_athlete if resource.athlete.blank?

      resource.validate
      collect_custom_errors

      if resource.errors.empty? && resource.athlete.errors.empty?
        resource.save!(validate: false)
        set_flash_message! :notice, :signed_up_but_unconfirmed
        redirect_to new_user_session_path
      else
        clean_up_passwords resource
        render :new, status: :unprocessable_content
      end
    end

    private

    def collect_custom_errors
      resource.athlete.errors.add(:gender, t('devise.registrations.new.gender_required')) if resource.athlete.gender.blank?
      return if resource.policy_accepted

      resource.errors.add(:policy_accepted, t('devise.registrations.new.policy_required'))
    end

    def sign_up_params
      params.expect(user: [:first_name, :last_name, :email, :policy_accepted, { athlete_attributes: [:gender] }])
    end
  end
end
