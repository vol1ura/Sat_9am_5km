# frozen_string_literal: true

RSpec.describe AthleteFinder, type: :service do
  context 'when argument is nil' do
    let(:parkrun_code) { Faker::Number.number(digits: 7) }

    before do
      stub_request(:get, %r{https://www\.parkrun\.com\.au/results/athleteresultshistory/\?athleteNumber=#{parkrun_code}})
        .to_raise(StandardError)
    end

    it 'returns nil' do
      expect(described_class.call(code_type: :parkrun_code, code: parkrun_code)).to be_nil
    end
  end
end
