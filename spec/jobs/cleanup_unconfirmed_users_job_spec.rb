# frozen_string_literal: true

RSpec.describe CleanupUnconfirmedUsersJob do
  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    it 'destroys only unconfirmed users older than 1 hour' do
      athlete = create(:athlete, :with_user)
      athlete.user.update!(confirmed_at: nil, created_at: 2.hours.ago)
      create(:user)
      create(:user).update!(confirmed_at: nil, created_at: 30.minutes.ago)

      expect { described_class.perform_now }
        .to change(Athlete, :count).by(-1)
        .and change(User, :count).by(-1)
      expect(Athlete).not_to exist(id: athlete.id)
      expect(User).not_to exist(id: athlete.user_id)
    end

    it 'keeps athlete with results' do
      athlete = create(:athlete, :with_user)
      athlete.user.update!(confirmed_at: nil, created_at: 2.hours.ago)
      create(:result, athlete:)

      described_class.perform_now

      expect(Athlete).to exist(id: athlete.id)
      expect(athlete.reload.user).to be_nil
    end

    it 'keeps athlete with volunteering' do
      athlete = create(:athlete, :with_user)
      athlete.user.update!(confirmed_at: nil, created_at: 2.hours.ago)
      create(:volunteer, athlete:)

      described_class.perform_now

      expect(Athlete).to exist(id: athlete.id)
    end
  end
end
