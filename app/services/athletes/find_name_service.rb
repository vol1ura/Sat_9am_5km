# frozen_string_literal: true

module Athletes
  class FindNameService < ApplicationService
    NAME_PATH = {
      parkrun_code: {
        url: 'https://www.parkrun.com.au/results/athleteresultshistory/?athleteNumber=%d',
      },
      fiveverst_code: {
        url: 'https://5verst.ru/userstats/%d/',
        xpath: '//div[@class="text-column"]/h1',
      },
      runpark_code: {
        url: 'https://runpark.ru/UserCard/A%d',
        xpath: '//body/div/div/h2',
      },
    }.freeze

    param :personal_code, reader: :private

    delegate :code_type, to: :personal_code

    def call
      return unless (xpath = NAME_PATH.dig(code_type, :xpath))

      Nokogiri::HTML.parse(fetch).xpath(xpath).text.tr("\u00A0", ' ').strip
    rescue StandardError => e
      Rollbar.error e, code: personal_code.id
      nil
    end

    private

    def fetch
      url = format NAME_PATH.dig(code_type, :url), personal_code.id
      sleep(1 + rand) unless Rails.env.test?
      response = Client.get url
      raise "Bad request. Body: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end
  end
end
