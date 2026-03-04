require 'rails_helper'

RSpec.describe Ability, type: :model do
  describe 'admin abilities' do
    let(:target_user) { create(:user) }

    context 'when user is a super_admin' do
      let(:user) { create(:user, role: :super_admin) }
      subject(:ability) { Ability.new(user) }

      it 'can manage all and destroy user' do
        expect(ability.can?(:manage, :all)).to be true
        expect(ability.can?(:destroy, target_user)).to be true
      end
    end

    context 'when user is an admin' do
      let(:user) { create(:user, role: :admin) }
      subject(:ability) { Ability.new(user) }

      it 'can manage other models but cannot destroy user' do
        expect(ability.can?(:manage, :all)).to be true
        expect(ability.can?(:destroy, target_user)).to be false
      end
    end
  end
end
