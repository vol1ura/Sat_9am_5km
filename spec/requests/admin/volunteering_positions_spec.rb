RSpec.describe '/admin/volunteering_positions' do
  let(:user) { create(:user, :admin) }
  let(:event) { create(:event) }
  let(:position) { create(:volunteering_position, event:) }

  before do
    FactoryBot.rewind_sequences
    sign_in user
  end

  describe 'GET /admin/volunteering_positions' do
    before do
      Volunteer.roles.keys.sample(3).each do |role|
        create(:volunteering_position, event:, role:)
      end
    end

    it 'renders a successful response' do
      get admin_event_volunteering_positions_url(event)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/volunteering_positions/1/edit' do
    it 'renders a successful response' do
      get edit_admin_event_volunteering_position_url(event, position)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/volunteering_positions' do
    let(:valid_attributes) do
      {
        volunteering_position: {
          role: :director,
          number: 1,
          rank: 1,
        },
      }
    end

    it 'creates a new position' do
      expect do
        post admin_event_volunteering_positions_url(event), params: valid_attributes
      end.to change(VolunteeringPosition, :count).by(1)
    end
  end

  describe 'PATCH /admin/volunteering_positions/1' do
    let(:valid_attributes) do
      {
        volunteering_position: {
          number: position.number.next,
        },
      }
    end

    it 'updates position' do
      expect do
        patch admin_event_volunteering_position_url(event, position), params: valid_attributes
      end.to change { position.reload.number }.by(1)
    end
  end
end
