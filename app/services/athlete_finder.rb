# frozen_string_literal: true

class AthleteFinder < ApplicationService
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
  private_constant :ANTI_BLOCK_PAUSE

  def initialize(personal_code)
    @code_type = personal_code.code_type
    @code = personal_code.id
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
    response_body = Client.get(url).body
    raise "Bad request. Body: #{response_body}" unless Net::HTTPSuccess

    response_body
  end
end
