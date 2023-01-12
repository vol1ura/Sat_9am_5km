RSpec.describe '/admin/activities' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  before do
    create(:permission, user: user, action: 'read', subject_class: 'Activity', event: event)
    sign_in user
  end

  describe 'GET /admin/activities' do
    before do
      create(:permission, user: user, action: 'manage', subject_class: 'VolunteeringPosition', event: event)
    end

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
end
