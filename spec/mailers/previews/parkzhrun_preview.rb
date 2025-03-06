# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/parkzhrun
class ParkzhrunPreview < ActionMailer::Preview
  delegate :success, :error, to: :ParkzhrunMailer
end
