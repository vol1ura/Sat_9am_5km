# frozen_string_literal: true

class BadgesController < ApplicationController
  def index
    badges_dataset = Badge.includes(image_attachment: :blob)
    @funrun_badges = badges_dataset.funrun_kind.order(received_date: :desc)
    @not_funrun_badges = badges_dataset.not_funrun_kind.order(kind: :asc, created_at: :desc)
  end

  def show
    @badge = Badge.find(params[:id])
    @trophies = @badge.trophies.includes(athlete: :club).order('date DESC', 'athletes.name').page(params[:page]).per(25)
  end
end
