# frozen_string_literal: true

RSpec.describe FivePlusAwardingJob do
  let(:initial_date) { Date.current.saturday? ? Date.current : Date.tomorrow.prev_week(:saturday) }
  let(:athlete) { create(:athlete) }
  let(:activity_id) { Activity.order(:date).last.id }

  before do
    create(:trophy, badge: create(:badge, kind: :five_plus))

    5.times.each do |idx|
      create(:result, athlete: athlete, activity_params: { date: initial_date - idx.weeks })
    end
  end

  it 'performs immediately' do
    expect { described_class.perform_later(activity_id) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  it 'updates result' do
    expect { described_class.perform_now(activity_id, with_expiration: true) }
      .to change { athlete.trophies.count }.by(1)
  end
end
