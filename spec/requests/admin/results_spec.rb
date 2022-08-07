RSpec.describe '/admin/results', type: :request do
  let(:user) { create :user }
  let(:activity) { create :activity }

  before do
    create :permission, user: user, action: 'read', subject_class: 'Result'
    sign_in user
  end

  describe 'GET /admin/results' do
    it 'renders a successful response' do
      create_list :result, 3, activity: activity
      get admin_activity_results_url(activity)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/results/1' do
    it 'renders a successful response' do
      result = create :result, activity: activity
      get admin_activity_result_url(activity, result)
      expect(response).to be_successful
    end
  end

  context 'with manage permission' do
    let(:activity) { create :activity }
    let(:results) { create_list :result, 3, activity: activity }

    before do
      create :permission, user: user, action: 'manage', subject_class: 'Result'
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
  end

  context 'without manage permission' do
    let(:activity) { create :activity }
    let(:results) { create_list :result, 3, activity: activity }

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
  end
end
