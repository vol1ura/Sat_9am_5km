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

  describe 'GET /.json' do
    let!(:club) { create(:club, description: 'Test club description') }

    def fetch_club_json
      get clubs_url(format: :json), headers: { host: 'test.ru' }
      response.parsed_body['clubs'].find { |c| c['slug'] == club.slug }
    end

    it 'lists clubs with description, logo, athletes and results counts only' do
      create(:result, athlete: create(:athlete, club:))

      expect(fetch_club_json).to eq(
        'slug' => club.slug,
        'name' => club.name,
        'description' => club.description,
        'logo_url' => nil,
        'updated_at' => club.reload.updated_at.iso8601,
        'athletes_count' => 1,
        'results_count' => 1,
      )
    end

    it 'includes pagination meta' do
      fetch_club_json

      expect(response.parsed_body['meta']).to include('page' => 1, 'total_pages' => 1, 'total_count' => 1)
    end

    it 'bumps updated_at when an athlete joins the club' do
      before_updated_at = club.updated_at

      travel_to(1.minute.from_now) { create(:athlete, club:) }

      expect(Time.zone.parse(fetch_club_json['updated_at'])).to be > before_updated_at
    end

    it 'bumps updated_at when an athlete leaves the club' do
      athlete = create(:athlete, club:)
      before_updated_at = club.reload.updated_at

      travel_to(1.minute.from_now) { athlete.update!(club: nil) }

      expect(Time.zone.parse(fetch_club_json['updated_at'])).to be > before_updated_at
    end

    it 'bumps updated_at when a club member is destroyed' do
      athlete = create(:athlete, club:)
      before_updated_at = club.reload.updated_at

      travel_to(1.minute.from_now) { athlete.destroy! }

      expect(club.reload.updated_at).to be > before_updated_at
    end

    it 'does NOT bump updated_at when a new result is added without a club change' do
      athlete = create(:athlete, club:)
      before_updated_at = club.reload.updated_at

      travel_to(1.minute.from_now) { create(:result, athlete:) }

      expect(fetch_club_json['updated_at']).to eq(before_updated_at.iso8601)
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
end
