FactoryBot.define do
  factory :permission do
    user
    action { Permission::ACTIONS.sample }
    subject_class { Permission::CLASSES.sample }
  end
end
