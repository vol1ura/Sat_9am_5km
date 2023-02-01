# frozen_string_literal: true

RSpec.describe Parkzhrun::ActivityCreator, type: :service do
  let!(:event) { create(:event, code_name: 'parkzhrun') }

  it 'creates Parkzhrun activity', :vcr do
    expect { described_class.call(Date.new(2023, 1, 28)) }.to change(Result, :count).by(17)
  end

  context 'when activity already exists' do
    let(:activity) { create(:activity, event: event) }

    before { create_list(:result, 3, activity: activity) }

    it 'skips activity processing' do
      expect { described_class.call(activity.date) }.not_to change(Result, :count)
    end
  end
end
