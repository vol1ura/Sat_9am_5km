# frozen_string_literal: true

module Cup
  class CallbackUrl
    PATH = '/api/v1/auth/s95/callback'
    PUBLIC_HOST = 'cup.s95.ru'
    LOCAL_HOSTS = %w[localhost 127.0.0.1].freeze
    LOCAL_PORTS = [80, 3000, 8080].freeze

    def self.parse(raw)
      new(URI.parse(raw.to_s)).tap(&:validate!)
    rescue URI::InvalidURIError
      raise ActionController::BadRequest
    end

    def initialize(uri)
      @uri = uri
    end

    def validate!
      raise ActionController::BadRequest unless allowed?
    end

    def with_token(token, state)
      "#{origin}#{PATH}?#{URI.encode_www_form(token:, state:)}"
    end

    private

    def allowed?
      @uri.userinfo.blank? && @uri.fragment.blank? && @uri.path == PATH && (public_https? || local_http?)
    end

    def public_https?
      @uri.scheme == 'https' && @uri.host == PUBLIC_HOST && @uri.port == 443
    end

    def local_http?
      Rails.env.local? && @uri.scheme == 'http' && LOCAL_HOSTS.include?(@uri.host) && LOCAL_PORTS.include?(@uri.port)
    end

    def origin
      default_port = @uri.scheme == 'https' ? 443 : 80
      host = @uri.port == default_port ? @uri.host : "#{@uri.host}:#{@uri.port}"
      "#{@uri.scheme}://#{host}"
    end
  end
end
