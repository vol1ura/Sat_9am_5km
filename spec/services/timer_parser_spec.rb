# frozen_string_literal: true

RSpec.describe TimerParser, type: :service do
  let(:activity) { create(:activity) }

  context 'when argument is nil' do
    it 'returns nil' do
      expect(described_class.call(activity, nil)).to be_nil
    end
  end

  context 'with valid timer file on iOS' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_ios.csv') }

    it 'appends result to activity' do
      expect { described_class.call(activity, file_timer) }.to change(activity.results, :size).to(5)
    end

    it 'change activity date according to timer file' do
      date = Date.parse('04/06/2022')
      expect { described_class.call(activity, file_timer) }.to change(activity, :date).to(date)
    end
  end

  context 'with zero time on first position in timer file on iOS' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_ios_zero.csv') }

    it 'appends result to activity' do
      expect { described_class.call(activity, file_timer) }.to change(activity.results, :size).to(5)
    end
  end

  context 'with valid timer file on Android' do
    let(:file_timer) { File.open('spec/fixtures/files/parkrun_timer_results_android.csv') }

    it 'appends result to activity' do
      expect { described_class.call(activity, file_timer) }.to change(activity.results, :size).to(6)
    end

    it 'change activity date according to timer file' do
      date = Date.parse('26/03/2022')
      expect { described_class.call(activity, file_timer) }.to change(activity, :date).to(date)
    end
  end
end
