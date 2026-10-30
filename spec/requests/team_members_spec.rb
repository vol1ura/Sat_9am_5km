# frozen_string_literal: true

RSpec.describe '/team' do
  before { host! 's95.ru' }

  describe 'GET /team' do
    it 'renders team members ordered by rank' do
      second = create(:team_member, rank: 2, athlete: create(:athlete, name: 'Second Member'))
      first = create(:team_member, rank: 1, athlete: create(:athlete, name: 'First Member'))
      get team_members_path
      expect(response).to be_successful
      expect(response.body.index(first.name)).to be < response.body.index(second.name)
    end
  end
end
