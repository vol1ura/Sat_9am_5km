# frozen_string_literal: true

class FavoriteEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event

  def update
    current_user.toggle_favorite_event(@event)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to events_path }
    end
  end

  private

  def find_event
    @event = Event.find_by!(code_name: params[:event_code_name])
  end
end
