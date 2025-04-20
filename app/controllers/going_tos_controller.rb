# frozen_string_literal: true

class GoingTosController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event
  before_action :find_athlete

  def create
    @athlete.update!(going_to_event: @event)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @event, notice: t('.success') }
    end
  end

  def destroy
    @athlete.update!(going_to_event: nil)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @event, notice: t('.success') }
    end
  end

  private

  def find_event
    @event = Event.where(active: true).find_by!(code_name: params[:event_code_name])
  end

  def find_athlete
    @athlete = current_user.athlete
  end
end
