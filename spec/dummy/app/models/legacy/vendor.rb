
require_relative 'vendor_address'
module Legacy
  class Vendor < ActiveRecord::Base
    establish_connection :legacy
    self.table_name = "vendor"
    self.primary_key = "vendor_id"
    #belongs_to :city
    ## has_many :coupons, dependent: :destroy
    has_many :vendor_addresses
    #has_many :coupons
    #has_many :punches
    #has_many :person_cards
    #has_many :punch_coupons
    #has_many :workflows
    #has_many :push_queues
    #has_many :referrals
    #has_many :person_referrals
    #has_many :surveys

    # don't destroy, just set a flag in row
    # don't really know how to do this
    # if this is implemented, then shouldn't need "dependent: :destroy" above?
    # def destroy
    # end
  end
end
