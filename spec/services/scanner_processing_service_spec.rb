# frozen_string_literal: true

RSpec.describe ScannerProcessingService, type: :service do
  subject(:service) { described_class.call(activity, file_scanner) }

  let(:activity) { build(:activity) }

  context 'when scanner file is nil' do
    let(:file_scanner) { nil }

    it { is_expected.to be_nil }
  end

  context 'with valid scanner file' do
    let(:file_scanner) { File.open('spec/fixtures/files/parkrun_scanner_results.csv') }

    it 'enqueues scanner processing job' do
      expect { service }.to have_enqueued_job(ScannerProcessingJob).once
    end
  end
end
