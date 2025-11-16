# frozen_string_literal: true

RSpec.describe '/athletes' do
  describe 'GET /athletes' do
    before { create_list(:athlete, 3) }

    context 'when athletes have same name' do
      before do
        create(:athlete, name: 'SOME Test')
        create(:athlete, name: 'Some Other')

        get athletes_url(q: 'Some')
      end

      it 'renders a successful response for name search' do
        expect(response).to be_successful
      end
    end

    context 'with single search result' do
      let!(:athlete) { create(:athlete, parkrun_code: 111_111) }

      it 'renders a successful response for ID search' do
        get athletes_url(q: 111_111)
        expect(response).to redirect_to(athlete_url(athlete))
      end
    end

    it 'renders a successful response for blank search' do
      get athletes_url(q: ' ')
      expect(response).to be_successful
    end
  end

  describe 'GET /athletes/1' do
    it 'renders a successful response' do
      athlete = create(:athlete)
      create_list(:result, 3, athlete:)
      get athlete_url(athlete)
      expect(response).to be_successful
    end
  end
end
