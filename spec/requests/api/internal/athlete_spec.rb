# frozen_string_literal: true

RSpec.describe '/api/internal/athlete' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let!(:athlete) { create(:athlete, user:, event:) }

  shared_examples 'have http status' do |status|
    specify { expect(response).to have_http_status status }
  end

  describe 'PUT /api/internal/athlete' do
    before { put api_internal_athlete_path, params: request_params, as: :json }

    context 'when set club' do
      let(:club) { create(:club) }
      let(:request_params) do
        {
          telegram_id: user.telegram_id,
          athlete: { club_id: club.id },
        }
      end

      it 'successfully assigns club to athlete' do
        expect(response).to be_successful
        expect(athlete.reload.club_id).to eq club.id
      end
    end

    context 'when reset event' do
      let(:request_params) do
        {
          telegram_id: user.telegram_id,
          athlete: { event_id: nil },
        }
      end

      it 'successfully resets home event' do
        expect(response).to be_successful
        expect(athlete.reload.event_id).to be_nil
      end
    end

    context 'when there is no such event' do
      let(:request_params) do
        {
          telegram_id: user.telegram_id,
          athlete: { event_id: event.id.next },
        }
      end

      it_behaves_like 'have http status', :not_acceptable
    end

    context 'when there is no user with such telegram id' do
      let(:request_params) do
        {
          telegram_id: Faker::Number.number(digits: 7),
          athlete: { event_id: event.id },
        }
      end

      it_behaves_like 'have http status', :not_found
    end

    context 'with invalid params' do
      let(:request_params) { { telegram_id: user.telegram_id } }

      it_behaves_like 'have http status', :bad_request
    end
  end
end
