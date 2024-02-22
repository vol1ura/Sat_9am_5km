# frozen_string_literal: true

RSpec.describe Permission do
  describe 'validations' do
    it { is_expected.not_to be_valid }

    it 'valid with user, action and subject_class' do
      permission = build_stubbed(:permission)
      expect(permission).to be_valid
    end
  end

  describe '#params' do
    let(:event) { build_stubbed(:event) }

    it 'returns params with id key' do
      permission = build_stubbed(:permission, subject_id: 1)
      expect(permission.params).to include(id: 1)
    end

    it 'returns params with event_id key' do
      permission = build_stubbed(:permission, event: event, subject_class: 'Activity')
      expect(permission.params).to include(event_id: event.id)
    end

    it 'returns params with activity key' do
      permission = build_stubbed(:permission, event: event, subject_class: 'Result')
      expect(permission.params).to include(activity: { event_id: event.id })
    end
  end
end
