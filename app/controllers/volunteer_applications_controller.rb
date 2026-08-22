# frozen_string_literal: true

class VolunteerApplicationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_idx

  def create
    if @volunteer_application.save
      @activity = @volunteer_application.activity
      @role = @volunteer_application.role
    else
      head :unprocessable_content
    end
  end

  def destroy
    @activity = @volunteer_application.activity
    @role = @volunteer_application.role
    @volunteer_application.destroy
  end

  private

  def resource_params
    params.expect(volunteer_application: %i[activity_id role])
  end

  def set_idx
    @idx = params[:idx]
  end
end
