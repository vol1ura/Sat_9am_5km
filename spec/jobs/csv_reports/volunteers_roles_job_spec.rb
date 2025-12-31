# frozen_string_literal: true

RSpec.describe CsvReports::VolunteersRolesJob do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:from_date) { 1.year.ago.to_date.to_s }
  let(:till_date) { 1.day.ago.to_date.to_s }

  describe 'queueing' do
    it 'schedules a job on the low queue' do
      expect { described_class.perform_later(event.id, user.id, from_date, till_date) }
        .to have_enqueued_job.on_queue('low').at(:no_wait)
    end
  end

  describe '#perform' do
    let(:job) { described_class.perform_now event.id, user.id, from_date, till_date }

    context 'when user has no telegram_id' do
      let(:user) { create(:user, :with_email) }

      before do
        allow(Telegram::Bot).to receive(:call)
        job
      end

      it 'does nothing' do
        expect(Telegram::Bot).not_to have_received(:call)
      end
    end

    context 'when user has telegram_id' do
      let(:activity) { create(:activity, event: event, date: Date.yesterday, published: true) }

      before do
        allow(Telegram::Bot).to receive(:call)
        create(:volunteer, role: :director, activity: activity)
        create(:volunteer, role: :marshal, activity: activity)
        job
      end

      it 'sends CSV with aggregated volunteers starting from the date' do
        expect(Telegram::Bot).to have_received(:call)
      end
    end

    context 'with error' do
      before do
        allow(Telegram::Bot).to receive(:call).and_raise(StandardError)
        allow(Rollbar).to receive(:error)
        job
      end

      it 'reports error to Rollbar' do
        expect(Rollbar)
          .to have_received(:error)
          .with(instance_of(StandardError), hash_including(user_id: user.id, event_id: event.id))
      end
    end
  end
end
