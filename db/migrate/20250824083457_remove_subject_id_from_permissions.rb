# frozen_string_literal: true

class RemoveSubjectIdFromPermissions < ActiveRecord::Migration[8.0]
  def up
    remove_column :permissions, :subject_id
  end

  def down
    add_column :permissions, :subject_id, :bigint
  end
end
