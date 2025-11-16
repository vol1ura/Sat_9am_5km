# frozen_string_literal: true

RSpec.describe ScannerParser, type: :service do
  let(:activity) { build(:activity) }

  context 'when scanner file is nil' do
    it 'returns nil' do
      expect(described_class.call(activity, nil)).to be_nil
    end
  end

  context 'with valid scanner file' do
    let(:file_scanner) { File.open('spec/fixtures/files/parkrun_scanner_results.csv') }

    before { allow(ScannerProcessingJob).to receive(:perform_later) }

    it 'scheduled job' do
      described_class.call(activity, file_scanner)
      expect(ScannerProcessingJob).to have_received(:perform_later).once
    end
  end
end
