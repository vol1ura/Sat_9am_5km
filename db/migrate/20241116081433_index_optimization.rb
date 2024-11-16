# frozen_string_literal: true

class IndexOptimization < ActiveRecord::Migration[7.2]
  def change
    remove_index :audits, %i[auditable_type auditable_id version], name: 'auditable_index'
    add_index :audits, %i[auditable_id auditable_type version], name: 'auditable_index'

    remove_index :athletes, :stats, using: :gin
    remove_index :badges, :info, using: :gin
  end
end
