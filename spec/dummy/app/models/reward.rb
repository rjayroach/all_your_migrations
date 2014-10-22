class Reward < ActiveRecord::Base
  belongs_to :merchant
  has_many :vouchers
end
