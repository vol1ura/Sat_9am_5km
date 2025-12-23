# frozen_string_literal: true

RSpec.describe CsvReports::EventAthletesJob do
  let(:event) { create(:event) }
  let(:user) { create(:user) }

  describe 'queueing' do
    it 'enqueues on low immediately' do
      expect { described_class.perform_later(event.id, user.id) }
        .to have_enqueued_job.on_queue('low').at(:no_wait)
    end
  end

  describe '#perform' do
    before { allow(Telegram::Bot).to receive(:call) }

    context 'when user has no telegram_id' do
      let(:user) { create(:user, :with_email) }

      it 'does nothing' do
        described_class.perform_now(event.id, user.id)
        expect(Telegram::Bot).not_to have_received(:call)
      end
    end

    context 'when user has telegram_id' do
      let(:activity) { create(:activity, event:) }

      before do
        create(:result, activity:)
        create(:result, activity:)
        create(:volunteer, activity:)
        described_class.perform_now(event.id, user.id)
      end

      it 'generates CSV and sends document to telegram' do
        expect(Telegram::Bot).to have_received(:call).with('sendDocument', hash_including(:form_data))
      end
    end

    context 'when an error occurs' do
      before do
        allow(Rollbar).to receive(:error)
        allow(Telegram::Bot).to receive(:call).and_raise(StandardError)
        described_class.perform_now(event.id, user.id)
      end

      it 'reports error to Rollbar' do
        expect(Rollbar)
          .to have_received(:error)
          .with(instance_of(StandardError), hash_including(user_id: user.id, event_id: event.id))
      end
    end
  end
end
