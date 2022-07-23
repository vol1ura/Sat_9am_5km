RSpec.describe ApplicationHelper, type: :helper do
  describe '#human_result_time' do
    context 'when time is nil' do
      it 'represent time in human format' do
        expect(helper.human_result_time(nil)).to eq 'XX:XX'
      end
    end

    context 'when time is less than 1 hour' do
      it 'represent time in human format' do
        time = Time.zone.parse('00:17:30')
        expect(helper.human_result_time(time)).to eq '17:30'
      end
    end

    context 'when time is over 1 hour' do
      it 'represent time in human format' do
        time = Time.zone.parse('01:02:17')
        expect(helper.human_result_time(time)).to eq '01:02:17'
      end
    end
  end

  describe '#human_result_pace' do
    context 'when time is less than 1 hour' do
      it 'represents pace' do
        time = Time.zone.parse('00:17:30')
        expect(helper.human_result_pace(time)).to eq '3:30'
      end
    end

    context 'when time is over 1 hour' do
      it 'represent time in human format' do
        time = Time.zone.parse('01:10:17')
        expect(helper.human_result_pace(time)).to eq '14:03'
      end
    end
  end

  describe '#human_activity_name' do
    it 'returns formatted string' do
      activity = create :activity
      expect(helper.human_activity_name(activity)).to match(/\d{4}-\d\d-\d\d - .+/)
    end
  end

  describe '#human_volunteer_role' do
    it 'returns translated role' do
      expect(helper.human_volunteer_role(Volunteer::ROLES.keys.sample)).to match(/\A[а-яА-ЯёЁ ]+\z/)
    end
  end
end
