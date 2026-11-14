# frozen_string_literal: true

class TeamMembersController < ApplicationController
  def index
    @team_members = TeamMember
      .joins(:country)
      .where(country: { code: top_level_domain })
      .order(:rank, :id)
      .includes(:athlete, photo_attachment: :blob)
  end
end
