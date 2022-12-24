RSpec.describe AddAthleteToResultJob do
  let(:activity) { create(:activity) }
  let(:result) { create(:result, activity: activity) }
  let(:athlete) { create(:athlete) }

  it 'performs immediately' do
    expect { described_class.perform_later(activity, []) }.to have_enqueued_job.on_queue('default').at(:no_wait)
  end

  it 'updates result' do
    described_class.perform_now(activity, ["A#{athlete.parkrun_code}", "P#{result.position}"])
    expect(result.reload.athlete).to eq athlete
  end
end
