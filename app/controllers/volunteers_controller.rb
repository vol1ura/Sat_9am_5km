# frozen_string_literal: true

class VolunteersController < ApplicationController
  load_and_authorize_resource

  def new
    @volunteer = Volunteer.new(activity_id: params[:activity_id], role: params[:role])
    render 'edit'
  end

  def edit; end

  def create
    render(@volunteer.save ? 'cell_name' : 'edit')
  end

  def update
    if @volunteer.update(resource_params)
      render 'cell_name'
    else
      render 'edit'
    end
  end

  private

  def resource_params
    params.require(:volunteer).permit(:athlete_id, :activity_id, :role)
  end
end
