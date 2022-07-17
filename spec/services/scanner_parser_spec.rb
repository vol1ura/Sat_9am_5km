# frozen_string_literal: true

RSpec.describe ScannerParser, type: :service do
  let(:activity) { build :activity }

  context 'when scanner file is nil' do
    it 'returns nil' do
      expect(described_class.call(activity, nil)).to be_nil
    end
  end

  context 'with valid scanner file' do
    let(:file_scanner) { File.open('spec/fixtures/files/parkrun_scanner_results.csv') }

    before do
      allow(AddAthleteToResultJob).to receive(:perform_later)
    end

    it 'scheduled job' do
      described_class.call(activity, file_scanner)
      expect(AddAthleteToResultJob).to have_received(:perform_later).at_least(:once)
    end
  end
end
