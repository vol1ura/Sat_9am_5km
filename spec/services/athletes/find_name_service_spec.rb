# frozen_string_literal: true

RSpec.describe Athletes::FindNameService, type: :service do
  context 'when argument is nil' do
    let(:parkrun_code) { Faker::Number.number(digits: 7) }

    before do
      stub_request(:get, %r{https://www\.parkrun\.com\.au/results/athleteresultshistory/\?athleteNumber=#{parkrun_code}})
        .to_raise(StandardError)
    end

    it 'returns nil' do
      personal_code = Athlete::PersonalCode.new(parkrun_code)
      expect(described_class.call(personal_code)).to be_nil
    end
  end
end
