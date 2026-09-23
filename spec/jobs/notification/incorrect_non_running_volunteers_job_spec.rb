# frozen_string_literal: true

RSpec.describe Notification::IncorrectNonRunningVolunteersJob do
  specify { expect { described_class.perform_later }.to have_enqueued_job.on_queue('low').at(:no_wait) }

  context 'when incorrect volunteers exist' do
    let!(:admin) { create(:user, role: :admin) }
    let(:activity) { create(:activity, published: true, date: 1.week.ago) }
    let(:other_activity) { create(:activity, published: true, date: activity.date) }
    let(:volunteer_athlete) { create(:athlete, :with_user) }
    let(:director_athlete) { create(:athlete, :with_user) }

    let(:message_matcher) { a_string_including('небеговой позиции') }

    before do
      create(:volunteer, activity: activity, athlete: volunteer_athlete, role: :marshal)
      create(:volunteer, activity: activity, athlete: director_athlete, role: :director)
      create(:result, activity: other_activity, athlete: volunteer_athlete)
      allow(Notification::User::Message).to receive(:call)
    end

    it 'sends message to admins, protocol responsible and volunteer athlete user' do
      described_class.perform_now

      [admin, volunteer_athlete.user, director_athlete.user].each do |user|
        expect(Notification::User::Message).to have_received(:call).with(user, message_matcher).once
      end
    end
  end
end
