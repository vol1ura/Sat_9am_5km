# frozen_string_literal: true

RSpec.describe Telegram::Notification::EventCancellationJob do
  it 'uses sequential queue' do
    expect { described_class.perform_later 1 }.to have_enqueued_job.on_queue('sequential')
  end

  describe '#perform' do
    let(:event) { create(:event) }

    before { allow(Telegram::Notification::User::Message).to receive(:call) }

    context 'when athletes with home event or going to event' do
      let!(:first_user) { create(:user).tap { |user| create(:athlete, event:, user:) } }
      let!(:second_user) { create(:user).tap { |user| create(:athlete, going_to_event: event, user: user) } }
      let!(:third_user) { create(:user).tap { |user| create(:athlete, event: event, going_to_event: event, user: user) } }

      it 'sends notifications to users with telegram_id' do
        described_class.perform_now event.id
        expect(Telegram::Notification::User::Message).to have_received(:call).with(first_user, kind_of(String))
        expect(Telegram::Notification::User::Message).to have_received(:call).with(second_user, kind_of(String))
        expect(Telegram::Notification::User::Message).to have_received(:call).with(third_user, kind_of(String))
      end
    end

    context 'when no matching athletes' do
      it 'does not send any notifications' do
        described_class.perform_now event.id
        expect(Telegram::Notification::User::Message).not_to have_received(:call)
      end
    end
  end
end
