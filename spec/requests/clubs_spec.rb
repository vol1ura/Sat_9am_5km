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
    let!(:club) { create(:club) }

    def club_json
      get club_url(club.slug, format: :json)
      response.parsed_body
    end

    context 'with members' do
      let!(:athlete) { create(:athlete, club:) }

      before { create_list(:result, 2, athlete:) }

      it 'renders club fields' do
        expect(club_json['club']).to eq('slug' => club.slug, 'name' => club.name)
      end

      it 'renders each member once with id and name only' do
        expect(club_json['athletes']).to eq([{ 'id' => athlete.id, 'name' => athlete.name }])
      end
    end

    it 'returns an empty roster for a club without members' do
      expect(club_json['athletes']).to eq([])
    end

    it 'returns not found for an unknown slug' do
      get club_url('unknown-slug-xyz', format: :json)

      expect(response).to have_http_status(:not_found)
    end
  end
end
