# frozen_string_literal: true

RSpec.describe '/admin/results' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:activity) { create(:activity, event: event, date: 1.week.ago) }
  let!(:results) { create_list(:result, 2, activity:) }

  before do
    create(:permission, user: user, action: 'read', subject_class: 'Result', event_id: event.id)
    sign_in user
  end

  describe 'GET /admin/results' do
    it 'renders a successful response' do
      create(:permission, user: user, action: 'manage', subject_class: 'Result', event_id: event.id)
      get admin_activity_results_url(activity)
      expect(response).to be_successful
      expect(response.body).to include('Удалить 🕑')
    end

    it 'renders csv' do
      get admin_activity_results_url(activity, format: :csv)
      expect(response).to be_successful
    end

    it 'renders athlete without tokens' do
      result = create(:result, activity: activity, athlete: nil)
      get admin_activity_results_url(activity)
      expect(response.body).to include I18n.t('common.without_token'), new_admin_athlete_path(result_id: result.id)
    end
  end

  context 'with manage permission' do
    before do
      create(:permission, user: user, action: 'manage', subject_class: 'Result', event_id: event.id)
      create(:permission, user: user, action: 'update', subject_class: 'Activity', event_id: event.id)
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

    describe 'DELETE /admin/activities/1/results/1/drop' do
      it 'removes result with next positions recalculation' do
        last_result_position = results.last.position
        delete drop_admin_activity_result_url(activity, results.first)
        expect(results.last.reload.position).to eq last_result_position.pred
      end
    end

    describe 'DELETE /admin/activities/1/results/1/drop_time' do
      it 'changes result total_time to next result total_time' do
        second_time = results.second.total_time
        delete drop_time_admin_activity_result_url(activity, results.first, format: :js)
        expect(results.first.reload.total_time).to eq second_time
        expect(results.last.reload.total_time).to be_nil
      end
    end

    describe 'DELETE /admin/activities/1/results/1/drop_athlete' do
      it 'changes result athlete to next result athlete' do
        second_athlete = results.second.athlete
        delete drop_athlete_admin_activity_result_url(activity, results.first, format: :js)
        expect(results.first.reload.athlete).to eq second_athlete
        expect(results.last.reload.athlete).to be_nil
      end
    end

    describe 'PUT /admin/activities/1/results/1/reset_athlete' do
      it 'removes athlete from result' do
        put reset_athlete_admin_activity_result_url(activity, results.first, format: :js)
        expect(results.first.reload.athlete).to be_nil
      end
    end

    describe 'DELETE /admin/activities/1/results' do
      it 'properly removes result' do
        expect do
          delete admin_activity_result_url(activity, results.second)
        end.to change { activity.results.order(:position).last.position }.by(-1)
      end
    end

    describe 'PUT /admin/activities/1/results/2/up' do
      it 'swaps athletes' do
        first_athlete = results.first.athlete
        second_athlete = results.second.athlete
        put up_admin_activity_result_url(activity, results.second, format: :js)
        expect(results.first.reload.athlete).to eq second_athlete
        expect(results.second.reload.athlete).to eq first_athlete
      end
    end

    describe 'PUT /admin/activities/1/results/1/down' do
      it 'swaps athletes' do
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
        create(:permission, user: user, action: 'manage', subject_class: 'Athlete')
        athlete = create(:athlete, gender: nil)
        result = create(:result, athlete:, activity:)
        patch gender_set_admin_activity_result_url(activity, result, gender: 'male', format: :js)
        expect(response).to be_successful
        expect(athlete.reload.gender).to eq 'male'
      end

      it 'does not assign gender without Athlete permission' do
        athlete = create(:athlete, gender: nil)
        result = create(:result, athlete:, activity:)

        patch gender_set_admin_activity_result_url(activity, result, gender: 'male', format: :js)

        expect(response.body).to include I18n.t('active_admin.access_denied.message')
        expect(athlete.reload.gender).to be_nil
      end
    end

    describe 'POST /admin/activities/:activity_id/results/batch_action' do
      before { activity.update!(published: false) }

      let(:valid_attributes) do
        {
          batch_action: :move_time,
          batch_action_inputs: { type: 'down', minutes: 1, seconds: 10 }.to_json,
          collection_selection: results.pluck(:id),
        }
      end

      it 'renders a successful response' do
        original_times = results.map(&:total_time)

        expect do
          post batch_action_admin_activity_results_url(activity, params: valid_attributes)
        end.not_to change(Audited::Audit.where(auditable_type: 'Result'), :count)
        expect(response).to redirect_to admin_activity_results_path(activity)
        expect(flash[:notice]).to include 'Произведён сдвиг времени (-70сек) для 2 результатов'
        expect(results.map { |result| result.reload.total_time }).to eq(original_times.map { |time| time - 70 })
      end

      it 'does not update results outside the parent activity' do
        foreign_result = create(:result)
        foreign_time = foreign_result.total_time
        valid_attributes[:collection_selection] = [foreign_result.id]

        expect do
          post batch_action_admin_activity_results_url(activity, params: valid_attributes)
        end.not_to(change { results.map { |result| result.reload.total_time } })
        expect(foreign_result.reload.total_time).to eq foreign_time
      end

      it 'does not update published results' do
        activity.update!(published: true)

        expect do
          post batch_action_admin_activity_results_url(activity, params: valid_attributes)
        end.not_to(change { results.map { |result| result.reload.total_time } })
      end
    end

    describe 'POST batch destroy for a published activity' do
      it 'does not destroy results' do
        activity.update!(published: true)

        expect do
          post batch_action_admin_activity_results_url(activity), params: {
            batch_action: :destroy,
            collection_selection: results.map(&:id),
          }
        end.not_to change(Result, :count)

        expect(response).to redirect_to root_path
      end
    end
  end

  context 'with Activity update permission' do
    before do
      create(:permission, user: user, action: 'update', subject_class: 'Activity', event_id: event.id)
      activity.update!(published: false)
    end

    it 'moves result time without Result update permission' do
      original_times = results.map(&:total_time)

      post batch_action_admin_activity_results_url(activity), params: {
        batch_action: :move_time,
        batch_action_inputs: { type: 'up', minutes: 1, seconds: 0 }.to_json,
        collection_selection: results.map(&:id),
      }

      expect(results.map { |result| result.reload.total_time }).to eq(original_times.map { |time| time + 60 })
    end
  end

  context 'with update permission' do
    before do
      create(:permission, user: user, action: 'update', subject_class: 'Result', event_id: event.id)
    end

    it 'updates a result through a custom action' do
      put reset_athlete_admin_activity_result_url(activity, results.first, format: :js)

      expect(response).to be_successful
      expect(results.first.reload.athlete).to be_nil
    end
  end

  context 'with destroy permission' do
    before do
      create(:permission, user: user, action: 'destroy', subject_class: 'Result', event_id: event.id)
    end

    it 'destroys a result through a custom action' do
      delete drop_admin_activity_result_url(activity, results.last)

      expect(response).to redirect_to admin_activity_results_path(activity)
      expect(Result).not_to exist(results.last.id)
    end
  end

  context 'without manage permission' do
    let(:result) { results.second }

    describe 'DELETE /admin/activities/1/results/2/drop_time' do
      it 'renders alert' do
        delete drop_time_admin_activity_result_url(activity, result, format: :js)
        expect(response).to be_successful
        expect(response.body).to include I18n.t('active_admin.access_denied.message')
      end
    end

    describe 'DELETE /admin/activities/1/results/2/drop_athlete' do
      it 'renders alert' do
        delete drop_athlete_admin_activity_result_url(activity, result, format: :js)
        expect(response).to be_successful
        expect(response.body).to include I18n.t('active_admin.access_denied.message')
      end
    end

    describe 'PUT /admin/activities/1/results/2/reset_athlete' do
      it 'renders alert' do
        put reset_athlete_admin_activity_result_url(activity, result, format: :js)
        expect(response).to be_successful
        expect(response.body).to include I18n.t('active_admin.access_denied.message')
      end
    end

    describe 'PUT /admin/activities/1/results/2/up' do
      it 'renders alert' do
        put up_admin_activity_result_url(activity, result, format: :js)
        expect(response).to be_successful
        expect(response.body).to include I18n.t('active_admin.access_denied.message')
      end
    end

    describe 'PUT /admin/activities/1/results/2/down' do
      it 'renders alert' do
        put down_admin_activity_result_url(activity, result, format: :js)
        expect(response).to be_successful
        expect(response.body).to include I18n.t('active_admin.access_denied.message')
      end
    end

    describe 'POST /admin/activities/1/results/2/insert_above' do
      it 'redirects to results' do
        post(
          insert_above_admin_activity_result_url(activity, result),
          headers: { 'HTTP_REFERER' => admin_activity_results_url(activity) },
        )
        expect(response).to redirect_to admin_activity_results_url(activity)
      end

      it 'appends new result' do
        expect do
          post insert_above_admin_activity_result_url(activity, result)
        end.not_to change(activity.results, :count)
      end
    end

    describe 'POST /admin/activities/:activity_id/results/batch_action' do
      it 'does not move result time' do
        activity.update!(published: false)
        original_times = results.map(&:total_time)

        post batch_action_admin_activity_results_url(activity), params: {
          batch_action: :move_time,
          batch_action_inputs: { type: 'up', minutes: 1, seconds: 0 }.to_json,
          collection_selection: results.map(&:id),
        }

        expect(results.map { |item| item.reload.total_time }).to eq original_times
      end
    end

    describe 'PATCH /admin/activities/1/results/2/gender_set' do
      it 'renders alert' do
        patch gender_set_admin_activity_result_url(activity, result, gender: 'male', format: :js)
        expect(response).to be_successful
        expect(response.body).to include 'У вас нет прав'
      end
    end
  end
end
