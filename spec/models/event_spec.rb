# frozen_string_literal: true

RSpec.describe Event do
  describe 'validation' do
    it { is_expected.not_to be_valid }

    it 'valid with name, code_name, town and place' do
      event = build(:event)
      expect(event).to be_valid
    end

    it 'invalid with existing code_name' do
      event = create(:event)
      new_event = build(:event, code_name: event.code_name)
      expect(new_event).not_to be_valid
    end
  end
end
