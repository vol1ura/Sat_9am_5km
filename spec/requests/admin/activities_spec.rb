# frozen_string_literal: true

RSpec.describe '/admin/activities' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  before do
    create(:permission, user: user, action: 'read', subject_class: 'Activity', event: event)
    sign_in user, scope: :user
  end

  describe 'GET /admin/activities' do
    before do
      create_list(:activity, 3, event:)
      user.admin!
    end

    it 'renders a successful response' do
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

  describe 'GET /admin/activities/1/edit' do
    before do
      create(:permission, user: user, action: 'update', subject_class: 'Activity', event: event)
      create(:permission, user: user, action: 'manage', subject_class: 'Result', event: event)
    end

    it 'renders a successful response' do
      activity = create(:activity, published: false, event: event)
      get edit_admin_activity_url(activity)
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
          date: Date.yesterday.strftime('%Y-%m-%d'),
          published: true,
          timer: File.open('spec/fixtures/files/parkrun_timer_results_ios.csv'),
          scanner0: File.open('spec/fixtures/files/parkrun_scanner_results.csv'),
        },
      }
    end

    it 'calls TimerParser and ScannerParser' do
      post admin_activities_url, params: valid_attributes
      expect(TimerParser).to have_received(:call).once
      expect(ScannerParser).to have_received(:call).exactly(Activity::MAX_SCANNERS).times
    end
  end

  describe 'DELETE /admin/activities/1' do
    let(:user) { create(:user, :admin) }
    let(:activity) { create(:activity, published:, event:) }

    before { delete admin_activity_url(activity) }

    context 'when not published' do
      let(:published) { false }

      it 'redirects to index' do
        expect(response).to redirect_to admin_activities_url
      end
    end

    context 'when published' do
      let(:published) { true }

      it 'redirects to resource' do
        expect(flash[:error]).to include 'Удаление опубликованного протокола запрещено'
        expect(response).to redirect_to admin_activity_url(activity)
      end
    end
  end

  describe 'PATCH /admin/activities/1/publish' do
    let(:user) { create(:user, :admin) }
    let(:activity) { create(:activity, published: false) }

    it 'redirects to resource with alert' do
      patch publish_admin_activity_url(activity)
      expect(flash[:error]).to include 'В протоколе нет результатов'
      expect(response).to redirect_to admin_activity_url(activity)
    end

    context 'with results' do
      it 'publishes protocol and redirects to resource' do
        create_list(:result, 2, activity:)
        patch publish_admin_activity_url(activity)
        expect(flash[:notice]).to include 'Протокол успешно опубликован на сайте'
        expect(response).to redirect_to admin_activity_url(activity)
        expect(activity.reload.published).to be true
      end
    end
  end

  describe 'PATCH /admin/activities/1/toggle_mode' do
    let(:user) { create(:user, :admin) }
    let(:activity) { create(:activity, published: false) }

    it 'toggles mode and redirects to resource' do
      patch toggle_mode_admin_activity_url(activity)
      expect(flash[:notice]).to include 'Автоматический режим активирован'
      expect(response).to redirect_to admin_activity_url(activity)
      expect(activity.reload.token).to be_present
    end
  end
end
