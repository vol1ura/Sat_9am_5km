# frozen_string_literal: true

RSpec.describe BarcodePrinter, type: :service do
  context 'with parkrun code' do
    let(:athlete) { build :athlete, fiveverst_code: nil }

    it 'returns svg xml document' do
      expect(described_class.call(athlete)).to include '<svg xmlns="http://www.w3.org/2000/svg"',
                                                       "<title>A#{athlete.parkrun_code}</title>"
    end
  end

  context 'with 5 verst code' do
    let(:athlete) { build :athlete, parkrun_code: nil }

    it 'returns svg xml document' do
      expect(described_class.call(athlete)).to include '<svg xmlns="http://www.w3.org/2000/svg"',
                                                       "<title>A#{athlete.fiveverst_code}</title>"
    end
  end
end
