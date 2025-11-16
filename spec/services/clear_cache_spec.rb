# frozen_string_literal: true

RSpec.describe ClearCache, type: :service do
  context 'when cache is clear' do
    before { allow(Rails.cache).to receive_messages(read: nil, write: true) }

    it 'writes cache' do
      expect(described_class.call).to be true
      expect(Rails.cache).to have_received(:write).once
    end
  end

  context 'when clearing was performing recently' do
    before { allow(Rails.cache).to receive_messages(read: 1.minute.ago, write: true) }

    it 'returns false' do
      expect(described_class.call).to be false
      expect(Rails.cache).not_to have_received(:write)
    end
  end
end
