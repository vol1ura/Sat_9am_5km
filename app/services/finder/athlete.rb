# frozen_string_literal: true

module Finder
  class Athlete < ApplicationService
    NAME_PATH = {
      parkrun_code: {
        url: 'https://www.parkrun.com.au/results/athleteresultshistory/?athleteNumber=',
        xpath: '//div[@id="content"]/h2'
      },
      fiveverst_code: {
        url: 'https://5verst.ru/userstats/?id=',
        xpath: '//div[@class="entry-content the-content text-column"]/h3'
      }
    }.freeze
    ANTI_BLOCK_PAUSE = 1.5

    def initialize(code_type:, code:)
      @code_type = code_type
      @code = code
    end

    def call
      parsed_data = Nokogiri::HTML.parse(fetch_data)
      name_element = parsed_data.xpath(NAME_PATH.dig(@code_type, :xpath))
      name_element.text.split(' - ').first
    rescue StandardError => e
      Rails.logger.error e.inspect
      nil
    end

    private

    def fetch_data
      url = NAME_PATH.dig(@code_type, :url) + @code.to_s
      sleep ANTI_BLOCK_PAUSE unless Rails.env.test?
      res = Client.get(url)
      raise "Bad request. Body: #{res.body}" unless Net::HTTPSuccess

      res.body
    end
  end
end
