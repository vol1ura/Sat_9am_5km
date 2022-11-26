RSpec.describe '/admin/results' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:activity) { create(:activity, event: event) }
  let!(:results) { create_list(:result, 3, activity: activity) }

  before do
    create(:permission, user: user, action: 'read', subject_class: 'Result', event_id: event.id)
    sign_in user
  end

  describe 'GET /admin/results' do
    it 'renders a successful response' do
      get admin_activity_results_url(activity)
      expect(response).to be_successful
    end

    it 'renders athlete without tokens' do
      result = create(:result, activity: activity, athlete: nil)
      get admin_activity_results_url(activity)
      expect(response.body).to include 'БЕЗ ТОКЕНА (создать)', new_admin_athlete_path(result_id: result.id)
    end
  end

  describe 'GET /admin/results/1' do
    it 'renders a successful response' do
      get admin_activity_result_url(activity, results.first)
      expect(response).to be_successful
    end
  end

  context 'with manage permission' do
    before do
      create(:permission, user: user, action: 'manage', subject_class: 'Result', event_id: event.id)
      Bullet.unused_eager_loading_enable = false
    end

    after do
      Bullet.unused_eager_loading_enable = true
    end

    describe 'PATCH /admin/activities/1/results/1' do
      it 'successfully add athlete to result' do
        result = create(:result, activity: activity, athlete: nil)
        athlete = create(:athlete)
        patch admin_activity_result_url(activity, result, code: athlete.parkrun_code)
        expect(response).to have_http_status :found
        expect(result.reload.athlete).to eq athlete
      end

      it 'cannot add athlete to result' do
        result = create(:result, activity: activity, athlete: nil)
        patch admin_activity_result_url(activity, result, code: 0)
        expect(response).to have_http_status :found
        expect(result.reload.athlete).to be_nil
      end
    end

    describe 'DELETE /admin/activities/1/results/1/drop_time' do
      it 'change result total_time to next result total_time' do
        second_time = results.second.total_time
        delete drop_time_admin_activity_result_url(activity, results.first, format: :js)
        expect(results.first.reload.total_time.strftime('%H:%M:%S')).to eq second_time.strftime('%H:%M:%S')
        expect(results.last.reload.total_time).to be_nil
      end
    end

    describe 'DELETE /admin/activities/1/results/1/drop_athlete' do
      it 'change result total_time to next result total_time' do
        second_athlete = results.second.athlete
        delete drop_athlete_admin_activity_result_url(activity, results.first, format: :js)
        expect(results.first.reload.athlete).to eq second_athlete
        expect(results.last.reload.athlete).to be_nil
      end
    end

    describe 'DELETE /admin/activities/1/results' do
      it 'properly remove result' do
        expect do
          delete admin_activity_result_url(activity, results.second)
        end.to change { activity.results.order(:position).last.position }.by(-1)
      end
    end

    describe 'PUT /admin/activities/1/results/2/up' do
      it 'swap athletes' do
        first_athlete = results.first.athlete
        second_athlete = results.second.athlete
        put up_admin_activity_result_url(activity, results.second, format: :js)
        expect(results.first.reload.athlete).to eq second_athlete
        expect(results.second.reload.athlete).to eq first_athlete
      end
    end

    describe 'PUT /admin/activities/1/results/1/down' do
      it 'swap athletes' do
        first_athlete = results.first.athlete
        second_athlete = results.second.athlete
        put down_admin_activity_result_url(activity, results.first, format: :js)
        expect(results.first.reload.athlete).to eq second_athlete
        expect(results.second.reload.athlete).to eq first_athlete
      end
    end

    describe 'POST /admin/activities/1/results/1/insert_above' do
      it 'redirects to results' do
        post insert_above_admin_activity_result_url(activity, results.first)
        expect(response).to redirect_to admin_activity_results_path(activity)
      end

      it 'appends new result' do
        first_athlete = activity.results.order(:position).first.athlete
        expect do
          post insert_above_admin_activity_result_url(activity, results.first)
        end.to change(activity.results, :count).by(1)
        new_results = activity.results.order(:position)
        expect(new_results.first.total_time).to be_nil
        expect(new_results.second.athlete).to eq first_athlete
      end
    end

    describe 'PATCH /admin/activities/1/results/1/gender_set' do
      it 'assigns gender for athlete' do
        athlete = create(:athlete, male: nil)
        result = create(:result, athlete: athlete, activity: activity)
        patch gender_set_admin_activity_result_url(activity, result, male: true, format: :js)
        expect(response).to be_successful
        expect(athlete.reload.male).to be_truthy
      end
    end
  end

  context 'without manage permission' do
    describe 'DELETE /admin/activities/1/results/1/drop_time' do
      it 'renders alert' do
        delete drop_time_admin_activity_result_url(activity, results.first, format: :js)
        expect(response).to be_successful
        expect(response.body).to include 'Не удалось'
      end
    end

    describe 'DELETE /admin/activities/1/results/1/drop_athlete' do
      it 'renders alert' do
        delete drop_athlete_admin_activity_result_url(activity, results.first, format: :js)
        expect(response).to be_successful
        expect(response.body).to include 'Не удалось'
      end
    end

    describe 'PUT /admin/activities/1/results/2/up' do
      it 'renders alert' do
        put up_admin_activity_result_url(activity, results.second, format: :js)
        expect(response).to be_successful
        expect(response.body).to include 'Проверьте корректность'
      end
    end

    describe 'PUT /admin/activities/1/results/1/down' do
      it 'renders alert' do
        put down_admin_activity_result_url(activity, results.first, format: :js)
        expect(response).to be_successful
        expect(response.body).to include 'Проверьте корректность'
      end
    end

    describe 'POST /admin/activities/1/results/1/insert_above' do
      it 'redirects to results' do
        post insert_above_admin_activity_result_url(activity, results.first)
        expect(response).to redirect_to admin_activity_results_path(activity)
      end

      it 'appends new result' do
        expect do
          post insert_above_admin_activity_result_url(activity, results.first)
        end.not_to change(activity.results, :count)
      end
    end

    describe 'PATCH /admin/activities/1/results/1/gender_set' do
      it 'renders alert' do
        patch gender_set_admin_activity_result_url(activity, results.first, male: true, format: :js)
        expect(response).to be_successful
        expect(response.body).to include 'У вас нет прав'
      end
    end
  end
end
