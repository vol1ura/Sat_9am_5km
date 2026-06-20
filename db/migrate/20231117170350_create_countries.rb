# frozen_string_literal: true

class CreateCountries < ActiveRecord::Migration[7.0]
  def up
    create_table :countries do |t|
      t.string :code, index: { unique: true }, null: false
      t.timestamps
    end

    add_reference :events, :country
    add_reference :clubs, :country

    add_foreign_key :events, :countries, on_delete: :cascade
    add_foreign_key :clubs, :countries, on_delete: :cascade
    change_column_null :events, :country_id, false
    change_column_null :clubs, :country_id, false

    remove_column :events, :country_code
    execute <<-SQL.squish
      DROP TYPE country_code;
    SQL
  end

  def down
    create_enum :country_code, %w[ru by rs]
    add_column :events, :country_code, :country_code, null: false, default: 'ru'

    remove_foreign_key :events, :countries
    remove_reference :events, :country
    remove_foreign_key :clubs, :countries
    remove_reference :clubs, :country
    drop_table :countries
  end
end
