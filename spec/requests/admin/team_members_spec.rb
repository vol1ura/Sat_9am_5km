# frozen_string_literal: true

RSpec.describe '/admin/team_members' do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  context 'when user is not admin' do
    let(:user) { create(:permission, action: 'manage').user }

    it 'denies access to the list' do
      get admin_team_members_url
      expect(response).to redirect_to(root_url)
    end

    it 'does not create a team member' do
      expect do
        post admin_team_members_url, params: { team_member: { athlete_id: create(:athlete).id } }
      end.not_to change(TeamMember, :count)
    end
  end

  describe 'GET /admin/team_members' do
    it 'renders a successful response' do
      create_list(:team_member, 3)
      get admin_team_members_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/team_members/1' do
    it 'renders a successful response' do
      team_member = create(:team_member)
      get admin_team_member_url(team_member)
      expect(response).to be_successful
      expect(response.body).to include(team_member.name, team_member.role)
    end
  end

  describe 'GET /admin/team_members/new' do
    it 'renders a successful response' do
      get new_admin_team_member_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/team_members/1/edit' do
    it 'renders a successful response' do
      team_member = create(:team_member)
      get edit_admin_team_member_url(team_member)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/team_members' do
    let(:athlete) { create(:athlete) }
    let(:valid_attributes) do
      {
        team_member: {
          athlete_id: athlete.id,
          role_translations: { ru: 'Координатор', en: 'Coordinator' },
          photo: fixture_file_upload('default.png', 'image/png'),
        },
      }
    end

    it 'creates a new team member with default rank' do
      expect do
        post admin_team_members_url, params: valid_attributes
      end.to change(TeamMember, :count).by(1)
      expect(TeamMember.last).to have_attributes(athlete: athlete, name: athlete.name, role: 'Координатор', rank: 1)
    end

    it 'does not create a team member without photo' do
      valid_attributes[:team_member].delete(:photo)
      expect do
        post admin_team_members_url, params: valid_attributes
      end.not_to change(TeamMember, :count)
    end
  end

  describe 'PATCH /admin/team_members/1' do
    it 'updates rank' do
      team_member = create(:team_member, rank: 1)
      patch admin_team_member_url(team_member), params: { team_member: { rank: 5 } }
      expect(team_member.reload.rank).to eq 5
    end
  end

  describe 'DELETE /admin/team_members/1' do
    it 'destroys the team member' do
      team_member = create(:team_member)
      expect do
        delete admin_team_member_url(team_member)
      end.to change(TeamMember, :count).by(-1)
    end
  end
end
