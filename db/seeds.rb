if Rails.env.development?
  User.create!(
      email: 'admin@test.com',
      password: '111111',
      password_confirmation: '111111',
      male: true,
      role: :admin
  )
end
