# frozen_string_literal: true

class AddSponsorMarkedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :sponsor_marked_at, :datetime
  end
end
