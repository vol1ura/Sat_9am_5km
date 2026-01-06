# frozen_string_literal: true

RSpec.describe TimerProcessingService, type: :service do
  subject(:timer_parser) { described_class.call(activity, file_timer) }

  let(:activity) { create(:activity) }

  before { allow(TimerProcessingJob).to receive(:perform_later) }

  shared_examples 'timer parsing' do
    it 'schedules results processing and change activity date according to timer file' do
      expect { timer_parser }.to change(activity, :date).to(expected_date)
      expect(TimerProcessingJob).to have_received(:perform_later).with(activity.id, expected_data).once
    end
  end

  context 'without file' do
    let(:file_timer) { nil }

    it 'skips processing' do
      expect(timer_parser).to be_nil
      expect(TimerProcessingJob).not_to have_received(:perform_later)
    end
  end

  context 'with valid stopwatch file on iOS' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_ios.csv') }
    let(:expected_date) { Date.new(2022, 6, 4) }
    let(:expected_data) do
      [
        { position: 1, total_time: '00:20:37' },
        { position: 2, total_time: '00:20:38' },
        { position: 3, total_time: '00:21:27' },
        { position: 4, total_time: '00:22:00' },
        { position: 5, total_time: '00:22:23' },
      ]
    end

    it_behaves_like 'timer parsing'
  end

  context 'with zero time on first position in timer file on iOS' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_ios_zero.csv') }
    let(:expected_date) { Date.new(2022, 11, 26) }
    let(:expected_data) do
      [
        { position: 1, total_time: '00:18:59' },
        { position: 2, total_time: '00:19:21' },
        { position: 3, total_time: '00:24:09' },
        { position: 4, total_time: '00:24:23' },
        { position: 5, total_time: '00:24:59' },
      ]
    end

    it_behaves_like 'timer parsing'
  end

  context 'with valid timer file on Android' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_android.csv') }
    let(:expected_date) { Date.new(2022, 3, 26) }
    let(:expected_data) do
      [
        { position: 1, total_time: '00:18:04' },
        { position: 2, total_time: '00:19:05' },
        { position: 3, total_time: '00:20:00' },
        { position: 4, total_time: '00:20:05' },
        { position: 5, total_time: '00:20:46' },
      ]
    end

    it_behaves_like 'timer parsing'
  end
end
