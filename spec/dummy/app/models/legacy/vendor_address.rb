
module Legacy
  class VendorAddress < ActiveRecord::Base
    establish_connection :legacy
    self.table_name = 'vendor_address'
    self.primary_key = 'vendor_addr_id'
    belongs_to :vendor
  end
end
