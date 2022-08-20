# frozen_string_literal: true

require 'net/http'

class Client
  DEFAULT_HEADERS = {
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language' => 'en-US,en;q=0.5',
    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:101.0) Gecko/20100101 Firefox/101.0'
  }.freeze
  private_constant :DEFAULT_HEADERS

  def self.get(...)
    new(...).get
  end

  def initialize(url, headers = {})
    @url = url
    @headers = DEFAULT_HEADERS.merge headers
  end

  def get
    Rails.logger.info { "GET #{@url}" }
    @request = Net::HTTP::Get.new(uri)
    set_headers
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl?) { |http| http.request(@request) }
    Rails.logger.info { "Response is #{response.message} (#{response.code})" }

    response
  end

  private

  def uri
    @uri ||= URI(@url)
  end

  def set_headers
    @headers.each do |key, value|
      @request[key] = value
    end
  end

  def use_ssl?
    uri.scheme == 'https'
  end
end
