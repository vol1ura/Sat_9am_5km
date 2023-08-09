RSpec.describe ApplicationHelper do
  describe '#human_result_time' do
    context 'when time is nil' do
      it 'represent time in human format' do
        expect(helper.human_result_time(nil)).to eq 'xx:xx'
      end
    end

    context 'when time is less than 1 hour' do
      it 'represent time in human format' do
        expect(helper.human_result_time(Result.total_time(17, 30))).to eq '17:30'
      end
    end

    context 'when time is over 1 hour' do
      it 'represent time in human format' do
        expect(helper.human_result_time(Result.total_time(1, 2, 17))).to eq '01:02:17'
      end
    end
  end

  describe '#human_result_pace' do
    context 'when time is less than 1 hour' do
      it 'represents pace' do
        expect(helper.human_result_pace(Result.total_time(17, 30))).to eq '3:30'
      end
    end

    context 'when time is over 1 hour' do
      it 'represent time in human format' do
        expect(helper.human_result_pace(Result.total_time(1, 10, 17))).to eq '14:03'
      end
    end
  end

  describe '#human_activity_name' do
    it 'returns formatted string' do
      activity = create(:activity)
      expect(helper.human_activity_name(activity)).to match(/\d\d [а-я]+ \d{4} - .+/)
    end
  end

  describe '#human_volunteer_role' do
    it 'returns translated role' do
      expect(helper.human_volunteer_role(Volunteer.roles.keys.sample)).to match(/\A[а-яА-ЯёЁ ]+\z/)
    end
  end

  describe '#athlete_external_link' do
    it 'returns parkrun link' do
      athlete = create(:athlete, fiveverst_code: nil)
      expect(helper.athlete_external_link(athlete)).to match(%r{https://www\.parkrun.*=#{athlete.parkrun_code}})
    end

    it 'returns 5 verst link' do
      athlete = create(:athlete, parkrun_code: nil)
      expect(helper.athlete_external_link(athlete)).to match(%r{https://5verst\.ru.*/#{athlete.fiveverst_code}/})
    end

    it 'returns nil' do
      athlete = create(:athlete, parkrun_code: nil, fiveverst_code: nil)
      expect(helper.athlete_external_link(athlete)).to be_nil
    end
  end

  describe '#sanitized_link_to' do
    it 'generates link with whitelisted attributes' do
      link_tag = helper.sanitized_link_to(
        '<script>test</script>',
        Faker::Internet.url(host: 'example.com', path: '/foobar.html'),
        target: '_blank',
        rel: 'noopener'
      )
      expect(link_tag).to include 'test', 'target="_blank"', 'rel="noopener"'
      expect(link_tag).not_to include '<script>', '</script>'
    end
  end
end
