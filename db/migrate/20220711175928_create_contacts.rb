class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.string :link
      t.integer :contact_type
      t.references :event, null: false, foreign_key: true
    end

    add_index :contacts, %i[event_id contact_type], unique: true
  end
end
