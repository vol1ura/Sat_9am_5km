class CreateWalletPassRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :wallet_pass_registrations do |t|
      t.references :athlete, null: false, foreign_key: true
      t.string :device_library_identifier, null: false
      t.string :push_token, null: false
      t.string :serial_number, null: false
      t.string :pass_type_identifier, null: false

      t.timestamps
    end

    add_index :wallet_pass_registrations, [:device_library_identifier, :serial_number], unique: true, name: 'idx_wallet_pass_registrations_on_device_and_serial'
  end
end
