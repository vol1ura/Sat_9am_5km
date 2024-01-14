# frozen_string_literal: true

RSpec.describe BarcodePrinter, type: :service do
  it 'returns svg xml document' do
    athlete = build(:athlete)
    expect(described_class.call(athlete)).to include '<svg version="1.1" xmlns="http://www.w3.org/2000/svg"', '</svg>'
  end
end
