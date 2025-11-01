# frozen_string_literal: true

RSpec.describe '/api/parkzhrun/activities' do
  describe 'POST /api/parkzhrun/activities' do
    let(:activity_attributes) { { date: '2023-03-25' } }
    let(:headers) do
      { 'Authorization' => Rails.application.credentials.parkzhrun_api_key }
    end

    context 'when header api key is invalid' do
      let(:headers) do
        { 'Authorization' => Faker::Crypto.sha256 }
      end

      it 'returns unauthorized response' do
        post api_parkzhrun_activities_url, params: activity_attributes, headers: headers, as: :json
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when activity successfully created' do
      before do
        allow(Parkzhrun::ActivityCreator).to receive(:call)
      end

      it 'renders successful response' do
        post api_parkzhrun_activities_url, params: activity_attributes, headers: headers, as: :json
        expect(response).to be_successful
      end
    end

    context 'when creation of activity failed' do
      before { allow(Parkzhrun::ActivityCreator).to receive(:call).and_raise(StandardError) }

      it 'renders not found for invalid id' do
        post api_parkzhrun_activities_url, params: activity_attributes, headers: headers, as: :json
        expect(response).to have_http_status :unprocessable_content
      end
    end
  end
end
