# frozen_string_literal: true

module Athletes
  class Finder < ApplicationService
    NAME_PATH = {
      parkrun_code: {
        url: 'https://www.parkrun.com.au/results/athleteresultshistory/?athleteNumber=%d',
        xpath: '//div[@id="content"]/h2/text()',
      },
      fiveverst_code: {
        url: 'https://5verst.ru/userstats/%d/',
        xpath: '//div[@class="text-column"]/h4',
      },
      runpark_code: {
        url: 'https://runpark.ru/UserCard/A%d',
        xpath: '//body/div/div/h2',
      },
    }.freeze
    ANTI_BLOCK_PAUSE = 1.5
    private_constant :ANTI_BLOCK_PAUSE

    def initialize(personal_code)
      @code_type = personal_code.code_type
      @code = personal_code.id
    end

    def call
      parsed_data = Nokogiri::HTML.parse(fetch)
      name_element = parsed_data.xpath(NAME_PATH.dig(@code_type, :xpath))
      name_element.text.tr("\u00A0", ' ').split(' - ').first&.strip
    rescue StandardError => e
      Rollbar.error e, code: @code
      nil
    end

    private

    def fetch
      url = format(NAME_PATH.dig(@code_type, :url), @code)
      sleep ANTI_BLOCK_PAUSE unless Rails.env.test?
      response = Client.get(url)
      raise "Bad request. Body: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end
  end
end
