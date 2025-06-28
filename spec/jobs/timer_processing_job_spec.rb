# frozen_string_literal: true

RSpec.describe TimerProcessingJob do
  subject(:perform_job) { described_class.perform_now activity.id, [{ position: 1, total_time: '00:17:42' }] }

  let(:activity) { create(:activity, published: false) }

  context 'with results' do
    it 'creates new result' do
      expect { perform_job }.to change(activity.results, :count).by(1)
      expect(activity.results.last.total_time.strftime('%H:%M:%S')).to eq '00:17:42'
    end

    it 'updates existing results if total_time is nil' do
      result = create(:result, activity: activity, total_time: nil, position: 1)
      expect { perform_job }.not_to change(activity.results, :count)
      expect(result.reload.total_time.strftime('%H:%M:%S')).to eq '00:17:42'
    end
  end
end
