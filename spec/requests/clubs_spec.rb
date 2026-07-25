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

      it 'excludes athletes with a hidden profile from the members list' do
        hidden_athlete = create(:athlete, name: 'Hidden Runner', club: club, hidden_profile: true)
        create(:result, athlete: hidden_athlete)

        get club_url(club.slug)

        expect(response.body).not_to include('Hidden Runner')
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
