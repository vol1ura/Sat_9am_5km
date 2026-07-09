# frozen_string_literal: true

RSpec.describe '/clubs' do
  describe 'GET /' do
    it 'renders a successful response' do
      clubs = create_list(:club, 2)
      clubs.each { |club| create_list(:athlete, 2, club:) }
      get clubs_url
      expect(response).to be_successful
    end
  end

  context 'with club' do
    let!(:club) { create(:club) }

    before do
      athletes = create_list(:athlete, 2, club:)
      athletes.each { |athlete| create_list(:result, 2, athlete:) }
    end

    describe 'GET /:slug' do
      it 'renders a successful response' do
        get club_url(club.slug)
        expect(response).to be_successful
      end
    end

    describe 'GET /:slug/last-week' do
      it 'renders a successful response' do
        get last_week_club_url(club.slug)
        expect(response).to be_successful
      end
    end

    describe 'GET /search' do
      it 'returns turbo stream with matched clubs within current TLD' do
        msk_club = create(:club, name: 'Moscow Runners')
        get search_clubs_url(q: 'runn'), headers: { 'Host' => 'test.ru', 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(response).to be_successful
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        expect(response.body).to include(msk_club.name)
        expect(response.body).not_to include(club.name)
      end
    end
  end

  describe 'GET /:slug.json' do
    let!(:club) { create(:club, description: 'Test club description') }

    def club_json
      get club_url(club.slug, format: :json)
      response.parsed_body
    end

    context 'with members' do
      let!(:athlete) { create(:athlete, club:) }
      let!(:result) { create(:result, athlete:) }
      let!(:volunteer_athlete) { create(:athlete, club:) }

      before { create(:volunteer, athlete: volunteer_athlete) }

      it 'renders club fields' do
        expect(club_json['club']).to eq(
          'slug' => club.slug,
          'name' => club.name,
          'description' => club.description,
          'logo_url' => nil,
        )
      end

      it 'renders aggregate counts' do
        expect(club_json).to include(
          'athletes_count' => 2,
          'total_results_count' => 1,
          'total_volunteering_count' => 1,
        )
      end

      it 'renders per-athlete roster fields' do
        json_athlete = club_json['athletes'].find { |a| a['id'] == athlete.id }

        expect(json_athlete).to eq(
          'id' => athlete.id,
          'name' => athlete.name,
          'results_count' => 1,
          'personal_best' => result.total_time,
          'volunteering_count' => 0,
        )
      end
    end

    it 'returns an empty roster for a club without members' do
      json = club_json

      expect(json['athletes']).to eq([])
      expect(json['athletes_count']).to eq(0)
    end

    it 'returns not found for an unknown slug' do
      get club_url('unknown-slug-xyz', format: :json)

      expect(response).to have_http_status(:not_found)
    end
  end
end
