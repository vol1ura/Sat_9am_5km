# frozen_string_literal: true

class VkPhotos < ApplicationService
  API_URL = "https://api.vk.com/method/photos.get?#{URI.encode_www_form(
    {
      owner_id: "-#{ENV.fetch('VK_GROUP_ID', 1)}",
      album_id: ENV.fetch('VK_ALBUM_ID', 1),
      access_token: ENV['VK_TOKEN'],
      v: '5.130',
    },
  )}".freeze
  MAX_WIDTH = 800

  private_constant :API_URL, :MAX_WIDTH

  def initialize(num)
    @num = num
  end

  def call
    Rails.cache.fetch('vk_photo_url_list', expires_in: 3.hours) do
      album_landscape_photos.sample(@num).map do |photo|
        photo[:sizes].max_by { |p| p[:width] > MAX_WIDTH ? 0 : p[:width] }[:url]
      end
    end
  rescue StandardError => e
    Rollbar.error e
    []
  end

  private

  def album_photos
    response = Net::HTTP.get_response(URI(API_URL))
    JSON.parse(response.body, symbolize_names: true).dig(:response, :items)
  end

  def album_landscape_photos
    (album_photos || []).filter do |photo|
      photo_params = photo.dig(:sizes, 0)
      photo_params[:width] > photo_params[:height]
    end
  end
end
