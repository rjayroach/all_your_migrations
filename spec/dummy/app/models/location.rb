class Location < ActiveRecord::Base
  include AllYourMigrations::Migratable
  belongs_to :merchant
  belongs_to :legacy, class_name: 'Legacy::VendorAddress'
end
