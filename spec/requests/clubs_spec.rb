# frozen_string_literal: true

RSpec.describe '/clubs' do
  describe 'GET /index' do
    it 'renders a successful response' do
      clubs = create_list(:club, 2)
      clubs.each { |club| create_list(:athlete, 2, club:) }
      get clubs_url
      expect(response).to be_successful
    end
  end

  context 'with club' do
    let(:club) { create(:club) }

    before do
      athletes = create_list(:athlete, 2, club:)
      athletes.each { |athlete| create_list(:result, 2, athlete:) }
    end

    describe 'GET /show' do
      it 'renders a successful response' do
        get club_url(club)
        expect(response).to be_successful
      end
    end

    describe 'GET /last_week' do
      it 'renders a successful response' do
        get last_week_club_url(club)
        expect(response).to be_successful
      end
    end
  end
end
