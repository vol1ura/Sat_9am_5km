# frozen_string_literal: true

RSpec.describe EmptyAthletesCleanupJob do
  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    around do |example|
      Bullet.n_plus_one_query_enable = false if defined?(Bullet)
      example.run
    ensure
      Bullet.n_plus_one_query_enable = true if defined?(Bullet)
    end

    it 'destroys athletes without user, results, volunteering and name' do
      athlete = create(:athlete, user: nil, name: nil)
      create(:athlete, user: nil, name: '')
      create(:athlete, :with_user, name: nil)
      create(:athlete, user: nil, name: 'John Doe')
      create(:athlete, user: nil, name: nil).tap { |a| create(:result, athlete: a) }
      create(:athlete, user: nil, name: nil).tap { |a| create(:volunteer, athlete: a) }

      expect { described_class.perform_now }.to change(Athlete, :count).by(-2)
      expect(Athlete).not_to exist(id: athlete.id)
    end
  end
end
