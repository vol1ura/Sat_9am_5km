# frozen_string_literal: true

RSpec.describe Parkzhrun::ActivityCreator, type: :service do
  subject(:service) { described_class.call(date) }

  let(:date) { '2023-01-28' }
  let!(:event) { create(:event, code_name: 'parkzhrun') }

  it 'creates Parkzhrun activity', :vcr do
    expect { service }.to change(Result, :count).by(17)
  end

  context 'when activity already exists' do
    let(:activity) { create(:activity, event:, date:) }

    before { create_list(:result, 3, activity:) }

    it 'skips activity processing' do
      expect { service }.not_to change(Result, :count)
    end
  end
end
