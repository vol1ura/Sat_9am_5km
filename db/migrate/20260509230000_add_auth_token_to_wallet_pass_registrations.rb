class AddAuthTokenToWalletPassRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :wallet_pass_registrations, :auth_token, :string
    
    WalletPassRegistration.reset_column_information
    WalletPassRegistration.find_each do |reg|
      reg.update_column(:auth_token, SecureRandom.hex(16))
    end

    change_column_null :wallet_pass_registrations, :auth_token, false
  end
end
