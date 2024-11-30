# frozen_string_literal: true

class ChangeInfoColumnDefault < ActiveRecord::Migration[8.0]
  def change
    change_column_default :badges, :info, from: '{}', to: {}
    change_column_default :trophies, :info, from: '{}', to: {}

    Badge.where(info: '{}').update_all(info: {})
    Trophy.where(info: '{}').update_all(info: {})
  end
end
