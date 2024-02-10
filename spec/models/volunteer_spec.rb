# frozen_string_literal: true

RSpec.describe Volunteer do
  describe 'validation' do
    subject(:volunteer) { described_class.new }

    it { is_expected.not_to be_valid }

    it 'strips comment before validation' do
      volunteer.comment = ' test '
      expect { volunteer.valid? }.to change(volunteer, :comment).to('test')
    end

    it 'valid with activity, athlete and role' do
      volunteer.role = 0
      volunteer.athlete = build :athlete
      volunteer.activity = build :activity
      expect(volunteer).to be_valid
    end
  end
end
