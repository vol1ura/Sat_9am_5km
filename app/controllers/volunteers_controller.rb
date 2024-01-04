# frozen_string_literal: true

class VolunteersController < ApplicationController
  load_and_authorize_resource except: :top

  def new
    @volunteer = Volunteer.new(activity_id: params[:activity_id], role: params[:role])
    render 'edit'
  end

  def edit; end

  def top
    athlete_ids =
      Volunteer
        .published
        .joins(activity: { event: :country })
        .where(country: { code: top_level_domain })
        .select(:athlete_id)
        .distinct(:athlete_id)
    @volunteers =
      Volunteer.published.where(athlete_id: athlete_ids).group(:athlete).order(Arel.sql('COUNT(*) DESC')).limit(50).count
  end

  def create
    render(@volunteer.save ? 'cell_name' : 'edit')
  end

  def update
    render(@volunteer.update(resource_params) ? 'cell_name' : 'edit')
  end

  private

  def resource_params
    params.require(:volunteer).permit(:athlete_id, :activity_id, :role)
  end
end
