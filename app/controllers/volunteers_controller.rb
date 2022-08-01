# frozen_string_literal: true

class VolunteersController < ApplicationController
  load_and_authorize_resource

  def new
    @volunteer = Volunteer.new(activity_id: params[:activity_id], role: params[:role])
    render 'edit'
  end

  def edit; end

  def create
    set_athlete
    render_cell
  end

  def update
    set_athlete
    render_cell
  end

  private

  def resource_params
    params.require(:volunteer).permit(:activity_id, :role)
  end

  def set_athlete
    athlete = Athlete.find_by(parkrun_code: params[:parkrun_code])
    @volunteer.athlete = athlete
  end

  def render_cell
    render(@volunteer.save ? 'cell_name' : 'edit')
  end
end
