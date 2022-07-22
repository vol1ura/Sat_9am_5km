# frozen_string_literal: true

RSpec.describe BarcodePrinter, type: :service do
  let(:athlete) { build :athlete }

  it 'returns svg xml document' do
    expect(described_class.call(athlete)).to include '<svg xmlns="http://www.w3.org/2000/svg"',
                                                     "<title>A#{athlete.parkrun_code}</title>"
  end
end
