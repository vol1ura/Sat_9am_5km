# frozen_string_literal: true

module Parkzhrun
  class Client
    def self.fetch(resource, param)
      response = ::Client.get(
        "https://parkzhrun.ru/wp-json/api/v1/#{resource}/#{param}",
        'Authorization' => Rails.application.credentials.parkzhrun_auth_key,
      )
      raise response.message unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)[resource]
    end
  end
end
