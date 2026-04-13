# frozen_string_literal: true

RSpec.describe EmptyClubsCleanupJob do
  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    it 'destroys empty clubs older than 6 months with short description' do
      create(:club, updated_at: 3.months.ago)
      create(:athlete, club: create(:club, updated_at: 7.months.ago))
      create(:club, description: 'A' * 150, updated_at: 7.months.ago)
      club = create(:club, description: 'Short', updated_at: 7.months.ago)

      expect { described_class.perform_now }.to change(Club, :count).by(-1)
      expect(Club).not_to exist(id: club.id)
    end
  end
end
