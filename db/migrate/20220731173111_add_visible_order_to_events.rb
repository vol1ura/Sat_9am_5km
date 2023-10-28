# frozen_string_literal: true

class AddVisibleOrderToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :visible_order, :integer
  end
end
