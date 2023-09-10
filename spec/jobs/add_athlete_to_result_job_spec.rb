RSpec.describe AddAthleteToResultJob do
  let(:activity_id) { create(:activity).id }
  let(:result) { create(:result, activity_id:) }
  let(:athlete) { create(:athlete) }

  it 'performs immediately' do
    expect { described_class.perform_later(activity_id, 'A1', 'P1') }.to have_enqueued_job.on_queue('default').at(:no_wait)
  end

  it 'updates result' do
    described_class.perform_now(activity_id, "A#{athlete.parkrun_code}", "P#{result.position}")
    expect(result.reload.athlete).to eq athlete
  end
end
