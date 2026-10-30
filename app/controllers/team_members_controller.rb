# frozen_string_literal: true

class TeamMembersController < ApplicationController
  def index
    @team_members = TeamMember.order(:rank, :id).includes(:athlete, photo_attachment: :blob)
  end
end
