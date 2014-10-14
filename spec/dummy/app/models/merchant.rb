class Merchant < ActiveRecord::Base
  include Migrations::Merchant
  has_many :regional_merchants, inverse_of: :merchant
end
