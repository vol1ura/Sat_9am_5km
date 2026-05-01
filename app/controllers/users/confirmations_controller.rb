# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation?confirmation_token=abcdef
    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])

      if resource.errors.empty?
        sign_in(resource_name, resource)
        set_flash_message!(:notice, :confirmed)
        respond_with_navigational(resource) { redirect_to user_path }
      else
        respond_with_navigational(resource.errors, status: :unprocessable_content) do
          render :new, status: :unprocessable_content
        end
      end
    end

    # GET /resource/confirmation/new
    def new
      self.resource = resource_class.new(email: params.dig(resource_name, :email))
    end

    # POST /resource/confirmation
    def create
      sign_out if user_signed_in?
      super
    end
  end
end
