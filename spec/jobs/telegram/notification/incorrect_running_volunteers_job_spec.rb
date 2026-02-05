# frozen_string_literal: true

RSpec.describe Telegram::Notification::IncorrectRunningVolunteersJob do
  specify { expect { described_class.perform_later }.to have_enqueued_job.on_queue('low').at(:no_wait) }

  context 'when incorrect volunteers exist' do
    let!(:admin) { create(:user, role: :admin) }
    let(:activity) { create(:activity, published: true, date: 1.week.ago) }
    let(:volunteer_athlete) { create(:athlete, :with_user) }
    let(:director_athlete) { create(:athlete, :with_user) }

    let(:message_matcher) { a_string_including('без результата в протоколе') }

    before do
      create(:volunteer, activity: activity, athlete: volunteer_athlete, role: :pacemaker)
      create(:volunteer, activity: activity, athlete: director_athlete, role: :director)
      create(:result, activity:)
      allow(Telegram::Notification::User::Message).to receive(:call)
    end

    it 'sends message to admins, protocol responsible and volunteer athlete user' do
      described_class.perform_now

      [admin, volunteer_athlete.user, director_athlete.user].each do |user|
        expect(Telegram::Notification::User::Message).to have_received(:call).with(user, message_matcher).once
      end
    end
  end
end
