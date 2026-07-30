# frozen_string_literal: true

RSpec.describe CsvReports::NewcomersJob do
  let(:event) { create(:event, name: 'Тестовый парк') }
  let(:other_event) { create(:event) }
  let(:user) { create(:user) }
  let(:from_date) { 1.month.ago.to_date.to_s }
  let(:till_date) { Time.zone.today.to_s }

  describe 'queueing' do
    it 'enqueues on low immediately' do
      expect { described_class.perform_later(event.id, user.id, from_date, till_date) }
        .to have_enqueued_job.on_queue('low').at(:no_wait)
    end
  end

  describe '#perform' do
    let(:job) { described_class.perform_now(event.id, user.id, from_date, till_date) }
    let(:debut_date) { 2.weeks.ago.to_date }
    let(:athlete) { create(:athlete, name: 'Новичок Иван') }

    before { allow(Telegram::Bot).to receive(:call) }

    context 'when user has telegram_id' do
      let!(:debut_activity) { create(:activity, event:, published: true, date: debut_date) }
      let!(:debut_result) { create(:result, activity: debut_activity, athlete:) }
      let!(:vol_before) do
        create(
          :volunteer,
          athlete:,
          activity: create(:activity, published: true, date: debut_date - 7.days),
        )
      end
      let!(:second_run) do
        create(
          :result,
          athlete:,
          activity: create(:activity, published: true, date: debut_date + 7.days),
        )
      end
      let!(:vol_after) do
        create(
          :volunteer,
          athlete:,
          activity: create(:activity, published: true, date: debut_date + 14.days),
        )
      end

      it 'generates CSV and sends document to telegram' do
        job
        expect(Telegram::Bot).to have_received(:call).with('sendDocument', hash_including(:form_data))
      end

      it 'includes newcomer stats in csv' do
        csv = nil
        allow(Telegram::Bot).to receive(:call) do |_method, form_data:|
          file_entry = form_data.find { |entry| entry.first == 'document' }
          csv = file_entry[1].read
        end

        job

        rows = CSV.parse(csv, headers: true)
        expect(rows.size).to eq(1)
        expect(rows.first['Участник']).to eq('Новичок Иван')
        expect(rows.first['Локация дебюта']).to eq('Тестовый парк')
        expect(rows.first['Число волонтёрств до дебюта']).to eq('1')
        expect(rows.first['Число забегов на текущий момент']).to eq('2')
        expect(rows.first['Число волонтёрств на текущий момент']).to eq('1')
      end
    end

    context 'when debut is outside selected period' do
      let!(:debut_activity) { create(:activity, event:, published: true, date: 3.months.ago.to_date) }

      before { create(:result, activity: debut_activity, athlete: create(:athlete)) }

      it 'does not include athlete in csv' do
        csv = nil
        allow(Telegram::Bot).to receive(:call) do |_method, form_data:|
          file_entry = form_data.find { |entry| entry.first == 'document' }
          csv = file_entry[1].read
        end

        job

        expect(CSV.parse(csv, headers: true)).to be_empty
      end
    end
  end
end
