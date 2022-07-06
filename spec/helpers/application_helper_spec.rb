RSpec.describe ApplicationHelper, type: :helper do
  describe '#human_result_time' do
    it 'represent time in human format' do
      time = Time.zone.now
      expect(helper.human_result_time(time)).to eq('this that')
    end
  end
end
