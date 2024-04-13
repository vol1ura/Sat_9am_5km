# frozen_string_literal: true

RSpec.describe AthleteStatsUpdateJob do
  let(:athlete) { create(:athlete) }

  it 'performs immediately' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  it 'updates result' do
    described_class.perform_now(athlete.id)
    expect(athlete.reload.stats).to eq({})
  end
end
