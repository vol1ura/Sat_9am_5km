# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/parkzhrun
class ParkzhrunPreview < ActionMailer::Preview
  def success
    ParkzhrunMailer.success
  end

  def error
    ParkzhrunMailer.error
  end
end
