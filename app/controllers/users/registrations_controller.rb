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

      if resource.athlete.blank?
        resource.build_athlete
        resource.validate
        resource.errors.add(:base, t('devise.registrations.new.gender_required'))
        clean_up_passwords resource
        return render :new, status: :unprocessable_content
      end

      if resource.save
        set_flash_message! :notice, :signed_up_but_unconfirmed
        redirect_to new_user_session_path
      else
        clean_up_passwords resource
        render :new, status: :unprocessable_content
      end
    end

    private

    def sign_up_params
      params.expect(user: [:first_name, :last_name, :email, { athlete_attributes: [:gender] }])
    end
  end
end
