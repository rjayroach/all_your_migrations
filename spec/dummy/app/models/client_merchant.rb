class ClientMerchant < ActiveRecord::Base
  include AllYourMigrations::Migratable
  belongs_to :merchant
end
