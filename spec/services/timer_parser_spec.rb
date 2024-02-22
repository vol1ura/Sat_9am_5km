# frozen_string_literal: true

RSpec.describe TimerParser, type: :service do
  subject(:timer_parser) { described_class.call(activity, file_timer) }

  let(:activity) { create(:activity) }

  context 'without file' do
    let(:file_timer) { nil }

    it { is_expected.to be_nil }
  end

  context 'with valid timer file on iOS' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_ios.csv') }

    it 'appends result to activity' do
      expect { timer_parser }.to change(activity.results, :size).to(5)
    end

    it 'change activity date according to timer file' do
      expect { timer_parser }.to change(activity, :date).to(Date.parse('04/06/2022'))
    end
  end

  context 'with zero time on first position in timer file on iOS' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_ios_zero.csv') }

    it 'appends result to activity' do
      expect { timer_parser }.to change(activity.results, :size).to(5)
    end
  end

  context 'with valid timer file on Android' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_android.csv') }

    it 'appends result to activity' do
      expect { timer_parser }.to change(activity.results, :size).to(6)
    end

    it 'change activity date according to timer file' do
      expect { timer_parser }.to change(activity, :date).to(Date.parse('26/03/2022'))
    end
  end
end
