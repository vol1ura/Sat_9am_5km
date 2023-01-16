# frozen_string_literal: true

RSpec.describe ClearCache, type: :service do
  context 'when cache is clear' do
    before do
      allow(Rails.cache).to receive(:read).and_return(nil)
      allow(Rails.cache).to receive(:write).and_return(true)
    end

    it 'writes cache' do
      expect(described_class.call).to be_truthy
      expect(Rails.cache).to have_received(:write).once
    end
  end

  context 'when clearing was performing recently' do
    before do
      allow(Rails.cache).to receive(:read).and_return(1.minute.ago)
      allow(Rails.cache).to receive(:write).and_return(true)
    end

    it 'returns false' do
      expect(described_class.call).to be_falsey
      expect(Rails.cache).not_to have_received(:write)
    end
  end
end
