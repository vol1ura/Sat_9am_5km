# frozen_string_literal: true

class AddCommentColumnToVolunteers < ActiveRecord::Migration[7.1]
  def change
    add_column :volunteers, :comment, :string
  end
end
