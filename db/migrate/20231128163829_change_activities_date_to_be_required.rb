# frozen_string_literal: true

class ChangeActivitiesDateToBeRequired < ActiveRecord::Migration[7.0]
  def change
    change_column_null :activities, :date, false
  end
end
