class CreateCountries < ActiveRecord::Migration[7.0]
  def up
    create_table :countries do |t|
      t.string :code, index: { unique: true }, null: false
      t.timestamps
    end

    russia = Country.create!(code: 'ru')

    add_reference :events, :country
    add_reference :clubs, :country

    Event.unscope(:order).distinct(:country_code).pluck(:country_code).each do |country_code|
      country = Country.find_or_create_by!(code: country_code)
      Event.where(country_code:).update_all(country_id: country.id)
    end

    Club.update_all(country_id: russia.id)

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
    create_enum :country_code, Country.pluck(:code)
    add_column :events, :country_code, :country_code, null: false, default: 'ru'

    Country.all.each do |country|
      country.events.update_all(country_code: country.code)
    end

    remove_foreign_key :events, :countries
    remove_reference :events, :country
    remove_foreign_key :clubs, :countries
    remove_reference :clubs, :country
    drop_table :countries
  end
end
