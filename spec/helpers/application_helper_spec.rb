# frozen_string_literal: true

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

    context 'when time is numeric value' do
      it 'represent time in human format' do
        time = Result.total_time(17, 30).to_f
        expect(helper.human_result_time(time)).to eq '17:30'
      end
    end

    context 'when time in string' do
      it 'represent time in human format' do
        time = Result.total_time(17, 30).to_f.to_s
        expect(helper.human_result_time(time)).to eq '17:30'
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
      activity = build_stubbed(:activity)
      expect(helper.human_activity_name(activity)).to match(/\d\d\.\d\d\.\d{4} - .+/)
    end
  end

  describe '#human_volunteer_role' do
    it 'returns translated role' do
      expect(helper.human_volunteer_role(Volunteer.roles.keys.sample)).to match(/\A[а-яА-ЯёЁ ]+\z/)
    end
  end

  describe '#athlete_code_id' do
    it 'returns parkrun link' do
      athlete = build(:athlete, fiveverst_code: nil)
      expect(helper.athlete_code_id(athlete)).to match(%r{https://www\.parkrun.*=#{athlete.parkrun_code}})
    end

    it 'returns 5 verst link' do
      athlete = build(:athlete, parkrun_code: nil)
      expect(helper.athlete_code_id(athlete)).to match(%r{https://5verst\.ru.*/#{athlete.fiveverst_code}/})
    end

    it 'returns runpark link' do
      athlete = build(
        :athlete,
        parkrun_code: nil,
        fiveverst_code: nil,
        runpark_code: (7 * (10**9)) + Faker::Number.number(digits: 5),
      )
      expect(helper.athlete_code_id(athlete)).to match(%r{https://runpark.ru/UserCard/A#{athlete.fiveverst_code}})
    end

    it 'returns s95 ID' do
      athlete = build_stubbed(:athlete, parkrun_code: nil, fiveverst_code: nil)
      expect(helper.athlete_code_id(athlete)).to eq(athlete.code)
    end
  end

  describe '#sanitized_link_to' do
    it 'generates link with whitelisted attributes' do
      link_tag = helper.sanitized_link_to(
        '<script>test</script>',
        Faker::Internet.url(host: 'example.com', path: '/foobar.html'),
        target: '_blank',
        rel: 'noopener',
      )
      expect(link_tag).to include 'test', 'target="_blank"', 'rel="noopener"'
      expect(link_tag).not_to include '<script>', '</script>'
    end
  end

  describe '#calculate_time_gap' do
    it 'returns nil if one of the times is blank' do
      expect(helper.calculate_time_gap('', '00:00:01')).to be_nil
    end

    it 'returns time gap' do
      expect(helper.calculate_time_gap('00:02:10', '00:01:40')).to eq('+0:30')
    end
  end
end
