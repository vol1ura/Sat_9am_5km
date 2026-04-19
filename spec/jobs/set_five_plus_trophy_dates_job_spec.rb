# frozen_string_literal: true

RSpec.describe SetFivePlusTrophyDatesJob do
  let(:initial_date) { Date.current.saturday? ? Date.current : Date.tomorrow.prev_week(:saturday) }
  let(:athlete) { create(:athlete) }
  let(:badge) { create(:badge, kind: :five_plus) }

  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    context 'when athlete has 5 consecutive participations' do
      before do
        3.times { |k| create(:result, athlete: athlete, activity_params: { date: initial_date - k.weeks }) }
        2.times { |k| create(:volunteer, athlete: athlete, activity_params: { date: initial_date - (k + 3).weeks }) }
      end

      let!(:trophy) { create(:trophy, badge: badge, athlete: athlete, date: initial_date) }

      it 'considers both results and volunteering' do
        described_class.perform_now
        trophy.reload

        expect(trophy.date).to be_present
      end
    end
  end
end
