# frozen_string_literal: true

class GoingTosController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event
  before_action :find_athlete

  def create
    if @athlete.update(going_to_event: @event)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @event, notice: t('.success') }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('going_to_form', partial: 'form') }
        format.html { redirect_to @event, alert: t('.error') }
      end
    end
  end

  def destroy
    if @athlete.update(going_to_event: nil)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @event, notice: t('.success') }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('going_to_form', partial: 'form') }
        format.html { redirect_to @event, alert: t('.error') }
      end
    end
  end

  private

  def find_event
    @event = Event.find_by!(code_name: params[:event_code_name])
  end

  def find_athlete
    @athlete = current_user.athlete
  end
end
