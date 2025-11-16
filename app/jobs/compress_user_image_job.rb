# frozen_string_literal: true

class CompressUserImageJob < ApplicationJob
  queue_as :low

  def perform(user_id)
    user = User.find user_id
    Users::ImageCompressor.call(user)
  end
end
