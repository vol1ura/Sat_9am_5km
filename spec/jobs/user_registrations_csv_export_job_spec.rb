# frozen_string_literal: true

RSpec.describe UserRegistrationsCsvExportJob do
  let(:user) { create(:user) }

  describe 'queueing' do
    it 'enqueues on low immediately' do
      expect { described_class.perform_later user.id }.to have_enqueued_job.on_queue('low').at(:no_wait)
    end
  end

  describe '#perform' do
    context 'when user has no telegram_id' do
      let(:user) { create(:user, :with_email) }

      before { allow(Telegram::Notification::File).to receive(:call) }

      it 'does nothing' do
        described_class.perform_now user.id
        expect(Telegram::Notification::File).not_to have_received(:call)
      end
    end

    context 'when user has telegram_id' do
      let!(:user) { create(:user, created_at: 1.week.ago) }

      before { allow(Telegram::Notification::File).to receive(:call) }

      it 'generates CSV and sends document to telegram' do
        described_class.perform_now user.id

        expect(Telegram::Notification::File).to have_received(:call).with(
          user,
          hash_including(
            file: instance_of(Tempfile),
            filename: a_string_matching(/user_registrations_\d+\.csv/),
            caption: a_string_including('Отчёт по регистрациям пользователей'),
          ),
        )
      end
    end

    context 'when an error occurs' do
      before do
        allow(Telegram::Notification::File).to receive(:call).and_raise(StandardError)
        allow(Rollbar).to receive(:error)
      end

      it 'reports error to Rollbar' do
        described_class.perform_now user.id

        expect(Rollbar).to have_received(:error).with(
          instance_of(StandardError),
          hash_including(user_id: user.id),
        )
      end
    end
  end
end
