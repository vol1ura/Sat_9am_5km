RSpec.describe '/admin/activities' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  before do
    create(:permission, user: user, action: 'read', subject_class: 'Activity', event: event)
    sign_in user
  end

  describe 'GET /admin/activities' do
    it 'renders a successful response' do
      create_list(:activity, 3, event: event)
      get admin_activities_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/activities/1' do
    it 'renders a successful response' do
      activity = create(:activity, published: false, event: event)
      get admin_activity_url(activity)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/activities' do
    before do
      create(:permission, user: user, action: 'manage', subject_class: 'Activity', event: event)
      allow(TimerParser).to receive(:call).and_return(nil)
      allow(ScannerParser).to receive(:call).and_return(nil)
    end

    let(:valid_attributes) do
      {
        activity: {
          event_id: event.id,
          published: true,
          timer: File.open('spec/fixtures/files/parkrun_timer_results_ios.csv'),
          scanner0: File.open('spec/fixtures/files/parkrun_scanner_results.csv')
        }
      }
    end

    it 'calls TimerParser and ScannerParser' do
      post admin_activities_url, params: valid_attributes
      expect(TimerParser).to have_received(:call).once
      expect(ScannerParser).to have_received(:call).exactly(Activity::MAX_SCANNERS).times
    end
  end

  describe 'DELETE /admin/activities/clear_cache' do
    before do
      allow(ClearCache).to receive(:call).and_return(clear_result)
      delete clear_cache_admin_activities_url
    end

    context 'when cache was cleared' do
      let(:clear_result) { true }

      it 'redirects' do
        expect(flash[:notice]).to be_present
        expect(response).to redirect_to admin_activities_url
      end
    end

    context 'when cache was not cleared' do
      let(:clear_result) { false }

      it 'redirects' do
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to admin_activities_url
      end
    end
  end
end
