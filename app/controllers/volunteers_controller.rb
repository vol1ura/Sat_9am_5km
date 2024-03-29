# frozen_string_literal: true

class VolunteersController < ApplicationController
  load_and_authorize_resource
  before_action :set_idx

  def new
    @volunteer = Volunteer.new(activity_id: params[:activity_id], role: params[:role])
    render 'edit'
  end

  def edit; end

  def create
    render :edit unless @volunteer.save
  end

  def update
    render(@volunteer.update(resource_params) ? :create : :edit)
  end

  private

  def resource_params
    params.require(:volunteer).permit(:athlete_id, :activity_id, :role, :comment)
  end

  def set_idx
    @idx = params[:idx]
  end
end
