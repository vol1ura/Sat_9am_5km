RSpec.describe Permission, type: :model do
  describe 'validations' do
    it { is_expected.not_to be_valid }

    it 'valid with user, action and subject_class' do
      permission = create :permission
      expect(permission).to be_valid
    end
  end

  describe '#params' do
    let(:event) { create :event }

    it 'returns params with id key' do
      permission = create :permission, subject_id: 1
      expect(permission.params).to include(id: 1)
    end

    it 'returns params with event_id key' do
      permission = create :permission, event: event, subject_class: 'Activity'
      expect(permission.params).to include(event_id: event.id)
    end
  end
end
