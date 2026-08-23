# frozen_string_literal: true

class AddDonorMarkedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :donor_marked_at, :datetime
  end
end
