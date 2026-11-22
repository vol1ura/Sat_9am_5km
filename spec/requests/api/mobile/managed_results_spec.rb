# frozen_string_literal: true

RSpec.describe '/api/mobile/activities/:activity_id/results/reorder' do
  subject(:reorder_results) do
    patch "/api/mobile/activities/#{activity.id}/results/reorder",
          params: { athlete_codes: [second_athlete.code, first_athlete.code, third_athlete.code, ''] },
          headers: headers,
          as: :json
  end

  let(:user) { create(:user, :admin, :with_athlete) }
  let(:activity) { create(:activity, published: false, date: Date.current) }
  let(:first_athlete) { create(:athlete) }
  let(:second_athlete) { create(:athlete) }
  let(:third_athlete) { create(:athlete) }
  let!(:first_result) do
    create(:result, activity: activity, athlete: first_athlete, position: 1, total_time: 20.minutes)
  end
  let!(:second_result) do
    create(:result, activity: activity, athlete: second_athlete, position: 2, total_time: 21.minutes)
  end
  let!(:third_result) do
    create(:result, activity: activity, athlete: third_athlete, position: 3, total_time: 22.minutes)
  end
  let!(:unassigned_result) do
    create(:result, activity: activity, athlete: nil, position: 4, total_time: 23.minutes)
  end
  let(:headers) do
    _session, token = MobileSession.issue_for!(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  before do
    create(:volunteer, athlete: user.athlete, activity: activity, role: :director)
  end

  it 'moves only athlete assignments while preserving positions and times' do
    reorder_results

    expect(response).to have_http_status(:no_content)
    expect([first_result.reload, second_result.reload, third_result.reload, unassigned_result.reload]).to contain_exactly(
      have_attributes(position: 1, total_time: 20.minutes.to_i, athlete: second_athlete),
      have_attributes(position: 2, total_time: 21.minutes.to_i, athlete: first_athlete),
      have_attributes(position: 3, total_time: 22.minutes.to_i, athlete: third_athlete),
      have_attributes(position: 4, total_time: 23.minutes.to_i, athlete: nil),
    )
  end
end
