# frozen_string_literal: true

RSpec.describe '/admin/utilities' do
  let(:user) { create(:user, :admin) }

  before { sign_in user, scope: :user }

  describe 'GET /admin/utilities' do
    before do
      create(:result, activity_params: { date: 1.month.ago })
      create(:volunteer, activity_params: { date: 10.months.ago })
    end

    it 'renders a successful response' do
      get admin_utilities_url
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/utilities/award_funrun_badge' do
    let!(:badge) { create(:badge) }

    it 'renders a successful response' do
      expect do
        post admin_utilities_award_funrun_badge_url, params: { activity_id: 1, badge_id: badge.id }
      end.to have_enqueued_job.on_queue('default').twice
      expect(response).to redirect_to admin_badge_trophies_path(badge.id)
    end
  end

  describe 'DELETE /admin/utilities/cache' do
    before do
      allow(ClearCache).to receive(:call).and_return(clear_result)
      delete admin_utilities_cache_url
    end

    context 'when cache was cleared' do
      let(:clear_result) { true }

      it 'redirects' do
        expect(flash[:notice]).to be_present
        expect(response).to redirect_to admin_utilities_url
      end
    end

    context 'when cache was not cleared' do
      let(:clear_result) { false }

      it 'redirects' do
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to admin_utilities_url
      end
    end
  end

  describe 'POST /admin/utilities/export_event_csv' do
    let!(:event_id) { create(:event).id }

    it 'enqueues csv export job' do
      post admin_utilities_export_event_csv_url, params: { event_id: }
      expect(response).to redirect_to admin_utilities_url
      expect(flash[:notice]).to include('Ждите отчёт в Telegram')
      expect(CsvReports::EventAthletesJob).to have_been_enqueued.with(event_id, user.id, nil, nil)
    end

    it 'does not enqueue csv export job if event is not selected' do
      post admin_utilities_export_event_csv_url
      expect(response).to redirect_to admin_utilities_url
      expect(flash[:alert]).to include('Мероприятие не выбрано')
      expect(CsvReports::EventAthletesJob).not_to have_been_enqueued
    end
  end

  describe 'POST /admin/utilities/export_volunteers_roles_csv' do
    let!(:event_id) { create(:event).id }

    it 'enqueues csv export job' do
      post admin_utilities_export_volunteers_roles_csv_url, params: { event_id: }
      expect(response).to redirect_to admin_utilities_url
      expect(flash[:notice]).to include('Ждите отчёт в Telegram')
      expect(CsvReports::VolunteersRolesJob).to have_been_enqueued.with(event_id, user.id, nil, nil)
    end

    it 'does not enqueue csv export job if event is not selected' do
      post admin_utilities_export_volunteers_roles_csv_url
      expect(response).to redirect_to admin_utilities_url
      expect(flash[:alert]).to include('Мероприятие не выбрано')
      expect(CsvReports::VolunteersRolesJob).not_to have_been_enqueued
    end
  end

  describe 'POST /admin/utilities/export_user_registrations_csv' do
    it 'enqueues csv export job' do
      post admin_utilities_export_user_registrations_csv_url, params: { from_date: '2023-01-01', till_date: '2023-12-31' }

      expect(response).to redirect_to admin_utilities_url
      expect(flash[:notice]).to include('Ждите отчёт в Telegram')
      expect(CsvReports::UserRegistrationsJob).to have_been_enqueued.with(user.id, '2023-01-01', '2023-12-31')
    end
  end
end
