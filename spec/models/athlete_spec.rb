# frozen_string_literal: true

RSpec.describe Athlete do
  it { is_expected.to be_valid }

  it 'invalid with existing parkrun_code' do
    parkrun_code = Faker::Number.number(digits: 6)
    create(:athlete, parkrun_code:)
    another_athlete = build(:athlete, parkrun_code:)
    expect(another_athlete).not_to be_valid
  end

  it 'invalid with incorrect format of personal bests' do
    athlete = build(:athlete, personal_bests: { '10k' => '17:00', 'half_marathon' => '1:12:00', 'marathon' => '03:70:00' })
    expect(athlete).not_to be_valid
    expect(athlete.errors).to include(:personal_best_10k, :personal_best_half_marathon, :personal_best_marathon)
  end

  it 'valid with correct format of personal bests' do
    athlete = build(:athlete, personal_bests: { 'half_marathon' => '01:19:59', 'marathon' => '03:01:00' })
    expect(athlete).to be_valid
  end

  it 'removes extra spaces from name' do
    athlete = build(:athlete, name: ' Test  TEST ')
    expect { athlete.save }.to change(athlete, :name).to('Test TEST')
  end

  describe '#find_or_scrape_by_code!' do
    context 'when such athlete exists in the database' do
      let(:athlete) do
        create(:athlete, :fiveverst, parkrun_code: Faker::Number.number(digits: 6), runpark_code: 7_000_998_502)
      end

      it 'returns athlete by parkrun code' do
        expect(described_class.find_or_scrape_by_code!(athlete.parkrun_code)).to eq athlete
      end

      it 'returns athlete by 5 verst code' do
        expect(described_class.find_or_scrape_by_code!(athlete.fiveverst_code)).to eq athlete
      end

      it 'returns athlete by sat_9am_5km code' do
        code = athlete.id + Athlete::SAT_9AM_5KM_BORDER
        expect(described_class.find_or_scrape_by_code!(code)).to eq athlete
      end

      it 'returns athlete by runpark code' do
        expect(described_class.find_or_scrape_by_code!(athlete.runpark_code)).to eq athlete
      end
    end

    context 'when such athlete is not exists in the database', vcr: ENV['CI'] ? {} : { re_record_interval: 1.month } do
      it 'skips parkrun site parsing' do
        athlete = create(:athlete, name: nil, parkrun_code: 875743)
        described_class.find_or_scrape_by_code!(athlete.parkrun_code)
        expect(athlete.reload.name).to be_nil
      end

      it 'parses 5 verst site to find athlete' do
        athlete = create(:athlete, name: nil, fiveverst_code: 790_069_891)
        described_class.find_or_scrape_by_code!(athlete.fiveverst_code)
        expect(athlete.reload.name).to eq 'Даниил ЯШНИКОВ'
      end

      it 'parses runpark site to find athlete' do
        athlete = create(:athlete, name: nil, runpark_code: 7_000_998_502)
        described_class.find_or_scrape_by_code!(athlete.runpark_code)
        expect(athlete.reload.name).to eq 'Ксения Кузьмина'
      end
    end
  end

  describe '#first_event_visit_dates' do
    let(:athlete) { create(:athlete) }
    let(:event_a) { create(:event) }
    let(:event_b) { create(:event) }

    it 'uses the earliest visit among results and volunteering' do
      create(:result, athlete: athlete, activity_params: { event: event_a, date: 2.weeks.ago.to_date })
      create(:volunteer, athlete: athlete, activity_params: { event: event_a, date: 3.weeks.ago.to_date })
      create(:result, athlete: athlete, activity_params: { event: event_b, date: Date.current })

      expect(athlete.first_event_visit_dates).to eq(
        event_a.id => 3.weeks.ago.to_date,
        event_b.id => Date.current,
      )
    end
  end

  describe '#first_finish_seconds' do
    let(:athlete) { create(:athlete) }
    let(:event) { create(:event) }
    let(:first_date) { 3.weeks.ago.to_date }

    before do
      create(
        :result,
        athlete: athlete,
        total_time: (18 * 60) + 17,
        activity_params: { date: first_date, event: event },
      )
      create(
        :result,
        athlete: athlete,
        total_time: (19 * 60) + 17,
        activity_params: { date: Date.current, event: event },
      )
    end

    it 'keeps the earliest result for a repeated finish second' do
      seconds = athlete.first_finish_seconds

      expect(seconds.keys).to eq([17])
      expect(seconds.fetch(17).date).to eq(first_date)
    end
  end
end
