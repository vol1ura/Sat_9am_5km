# frozen_string_literal: true

RSpec.describe Athlete do
  it { is_expected.to be_valid }

  it 'invalid with existing parkrun_code' do
    parkrun_code = Faker::Number.number(digits: 6)
    create(:athlete, parkrun_code:)
    another_athlete = build(:athlete, parkrun_code:)
    expect(another_athlete).not_to be_valid
  end

  it 'removes extra spaces from name' do
    athlete = build(:athlete, name: ' Test  TEST ')
    expect { athlete.save }.to change(athlete, :name).to('Test TEST')
  end

  describe '#gender' do
    context 'when male is true' do
      it 'returns "мужчина"' do
        athlete = create(:athlete, male: true)
        expect(athlete.gender).to eq 'мужчина'
      end
    end

    context 'when male is false' do
      it 'returns "женщина"' do
        athlete = create(:athlete, male: false)
        expect(athlete.gender).to eq 'женщина'
      end
    end

    context 'when male is nil' do
      it 'returns nil' do
        athlete = create(:athlete, male: nil)
        expect(athlete.gender).to be_nil
      end
    end
  end

  describe '#duplicates' do
    it 'finds duplicated athletes by name case insensitive' do
      create(:athlete, name: 'Test Name', fiveverst_code: nil)
      create(:athlete, name: 'Name Test', fiveverst_code: nil)
      create(:athlete, name: 'test NAME', parkrun_code: nil)
      expect(described_class.duplicates.size).to eq 3
    end
  end

  describe '#find_or_scrape_by_code!' do
    context 'when such athlete exists in the database' do
      let(:athlete) { create(:athlete) }

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
    end

    context 'when such athlete is not exists in the database', vcr: ENV['CI'] ? {} : { re_record_interval: 1.month } do
      it 'parses parkrun site to find athlete' do
        athlete = create(:athlete, name: nil, parkrun_code: 875743)
        described_class.find_or_scrape_by_code!(athlete.parkrun_code)
        expect(athlete.reload.name).to eq 'Юрий ВОЛОДИН'
      end

      it 'parses 5 verst site to find athlete' do
        athlete = create(:athlete, name: nil, fiveverst_code: 790069891)
        described_class.find_or_scrape_by_code!(athlete.fiveverst_code)
        expect(athlete.reload.name).to eq 'Даниил ЯШНИКОВ'
      end

      it 'parses runpark site to find athlete' do
        athlete = create(:athlete, name: nil, fiveverst_code: nil, runpark_code: 7000998502)
        described_class.find_or_scrape_by_code!(athlete.runpark_code)
        expect(athlete.reload.name).to eq 'Ксения Кузьмина'
      end
    end
  end
end
