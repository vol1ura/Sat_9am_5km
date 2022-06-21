# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  has_many :results, dependent: :destroy
  has_many :activities, through: :results

  validates :parkrun_id, uniqueness: true, allow_nil: true


  enum role: { admin: 0, uploader: 1 }
end
