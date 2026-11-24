# frozen_string_literal: true

RSpec.describe 'GET /athletes/latest_runs' do
  let(:path) { '/athletes/latest_runs' }

  it 'returns an empty list when ids are empty' do
    get path

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq('runs' => [])
  end

  it 'rejects more than 100 ids' do
    get path, params: { ids: (1..101).to_a }

    expect(response).to have_http_status(:unprocessable_content)
  end

  context 'when athletes have several runs' do
    let(:event) { create(:event, name: 'ЗИЛ', code_name: 'zil') }
    let(:parkrun_athlete) { create(:athlete, parkrun_code: 875_743) }
    let(:s95_athlete) { create(:athlete, parkrun_code: 100_001) }
    let(:s95_code) { Athlete::SAT_9AM_5KM_BORDER + s95_athlete.id }
    let!(:parkrun_latest) do
      create(
        :result,
        athlete: parkrun_athlete,
        total_time: 1530,
        activity_params: { date: Date.new(2026, 11, 21), event: event },
      )
    end
    let!(:s95_latest) do
      create(
        :result,
        athlete: s95_athlete,
        total_time: 1600,
        activity_params: { date: Date.new(2026, 11, 21), event: event },
      )
    end

    before do
      create(
        :result,
        athlete: parkrun_athlete,
        total_time: 1500,
        activity_params: { date: Date.new(2026, 11, 14), event: event },
      )
      create(
        :result,
        athlete: parkrun_athlete,
        total_time: 1400,
        activity_params: { date: Date.new(2026, 11, 22), event: event, published: false },
      )
    end

    it 'returns the latest published runs for personal codes' do
      get path, params: { ids: [parkrun_athlete.parkrun_code, s95_code, 0] }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('runs')).to contain_exactly(
        parkrun_run(parkrun_latest),
        s95_run(s95_latest),
      )
    end
  end

  it 'does not insert rows' do
    athlete = create(:athlete)

    expect { get path, params: { ids: [athlete.id] } }.not_to change(Result, :count)
  end

  def parkrun_run(result)
    {
      'code' => 875_743,
      'athlete_id' => parkrun_athlete.id,
      'activity_id' => result.activity_id,
      'date' => '2026-11-21',
      'total_time' => '25:30',
      'event' => { 'id' => event.id, 'code_name' => 'zil', 'name' => 'ЗИЛ' },
    }
  end

  def s95_run(result)
    {
      'code' => s95_code,
      'athlete_id' => s95_athlete.id,
      'activity_id' => result.activity_id,
      'date' => '2026-11-21',
      'total_time' => '26:40',
      'event' => { 'id' => event.id, 'code_name' => 'zil', 'name' => 'ЗИЛ' },
    }
  end
end
