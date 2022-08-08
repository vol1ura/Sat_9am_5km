# frozen_string_literal: true

require 'net/http'

class VkPhotos < ApplicationService
  OWNER_ID = '-212432495' # https://vk.com/sat9am5km
  TOKEN = ENV['VK_TOKEN'].freeze

  def initialize(num)
    @num = num
  end

  def call
    random_photos = filter_landscape(latest_album_photos).sample(@num)
    random_photos.map do |photo|
      photo['sizes'].sort_by { |p| -p['height'] }.dig(4, 'url')
    end
  rescue StandardError => e
    Rails.logger.error e.inspect
    []
  end

  private

  def api_uri(method, album_id = nil)
    uri = URI("https://api.vk.com/method/#{method}")
    params = {
      owner_id: OWNER_ID,
      access_token: TOKEN,
      v: '5.130'
    }
    params[:album_id] = album_id if album_id
    uri.query = URI.encode_www_form(params)
    uri
  end

  def request(...)
    uri = api_uri(...)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end

  def latest_album_photos
    all_albums = request('photos.getAlbums')
    album_id = all_albums.dig('response', 'items', rand(3), 'id')
    album_photos = request('photos.get', album_id)
    album_photos.dig('response', 'items')
  end

  def filter_landscape(photos)
    (photos || []).filter do |photo|
      photo_params = photo.dig('sizes', 0)
      photo_params['width'] > photo_params['height']
    end
  end
end
