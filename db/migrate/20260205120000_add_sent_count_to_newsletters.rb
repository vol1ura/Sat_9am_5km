# frozen_string_literal: true

class AddSentCountToNewsletters < ActiveRecord::Migration[8.1]
  def change
    add_column :newsletters, :sent_count, :integer, null: false, default: 0
  end
end
