# frozen_string_literal: true

RSpec.describe Ability do
  describe 'admin permissions' do
    let(:admin) { create(:user, role: :admin) }
    let(:super_admin) { create(:user, role: :super_admin) }
    let(:regular_user) { create(:user) }

    it 'admin cannot destroy user' do
      ability = Ability.new(admin)
      expect(ability).not_to be_able_to(:destroy, regular_user)
    end

    it 'super_admin can destroy user' do
      ability = Ability.new(super_admin)
      expect(ability).to be_able_to(:destroy, regular_user)
    end

    it 'admin can manage all' do
      ability = Ability.new(admin)
      expect(ability).to be_able_to(:manage, :all)
    end
  end
end
