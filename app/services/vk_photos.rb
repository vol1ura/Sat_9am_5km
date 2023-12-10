# frozen_string_literal: true

class VkPhotos < ApplicationService
  API_QUERIES = {
    owner_id: "-#{ENV.fetch('VK_GROUP_ID', 1)}".freeze,
    access_token: ENV['VK_TOKEN'],
    v: '5.130',
  }.freeze
  ALBUMS_SET_SIZE = 3
  MAX_WIDTH = 800

  private_constant :API_QUERIES, :ALBUMS_SET_SIZE, :MAX_WIDTH

  def initialize(num)
    @num = num
  end

  def call
    random_photos = filter_landscape(latest_album_photos).sample(@num)
    random_photos.map do |photo|
      photo['sizes'].filter { |p| p['width'] < MAX_WIDTH }.max_by { |p| p['width'] }['url']
    end
  rescue StandardError => e
    Rollbar.error e
    []
  end

  private

  def api_uri(method, options = {})
    uri = URI("https://api.vk.com/method/#{method}")
    params = API_QUERIES.merge(options)
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
    album_id = all_albums.dig('response', 'items', rand(ALBUMS_SET_SIZE), 'id')
    album_photos = request('photos.get', album_id:)
    album_photos.dig('response', 'items')
  end

  def filter_landscape(photos)
    (photos || []).filter do |photo|
      photo_params = photo.dig('sizes', 0)
      photo_params['width'] > photo_params['height']
    end
  end
end
