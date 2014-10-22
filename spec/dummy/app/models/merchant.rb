class Merchant < ActiveRecord::Base
  include Migrations::Merchant
  has_many :regional_merchants, inverse_of: :merchant
  has_many :locations
  has_many :rewards
  has_many :vouchers, through: :rewards
end
