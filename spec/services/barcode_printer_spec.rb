# frozen_string_literal: true

RSpec.describe BarcodePrinter, type: :service do
  it 'returns svg xml document' do
    expect(described_class.call('A123456', module_size: 4))
      .to include '<svg version="1.1" xmlns="http://www.w3.org/2000/svg"', '</svg>'
  end
end
