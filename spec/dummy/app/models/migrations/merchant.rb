module Migrations
  module Merchant
    extend ActiveSupport::Concern
    include AllYourMigrations::Migratable

    module ClassMethods

      # Insert new records created since last import
      def insert_new_merchants
        insert_into(self).values(:legacy_id,
                                 :created_at,
                                 :updated_at,
                                 :name,
                                 :state,
                                 :logo,
                                 :stamp,
                                 :uses_amex,
                                 :amex_issuer_code)
                         .from(Legacy::Vendor.where('vendor_id > ?', last_migrated_id)
                                             .select(:vendor_id,
                                                     :create_date,
                                                     :last_updated_date,
                                                     :name,
                                                     'IF(`vendor`.`active` = 1, 4, 5)',
                                                     :vendor_logo,
                                                     "'perx_stamp.png'",
                                                     :uses_amex,
                                                     :amex_issuer_id))
                         #.key_on(:legacy_id)
                         #.legacy_tables([:hi]) #self.legacy_tables)
      end

      def update_addresses
        update_into(self).from(Legacy::Vendor.all)
                         .where('j is true')
                         .set('a = b')
                         .set('c = d')
                         #.legacy_tables(self.legacy_tables)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.belongs_to :legacy, class_name: 'Legacy::Vendor'
      base.migrate_option_key = :legacy_id
      #base.migrate_option_legacy_tables = nil
      #base.belongs_to_migration :nuke_and_bang, actions: [:truncate, :big_bang], before: Merchant, after: Merchant
      base.belongs_to_migration :nuke_and_bang, actions: [:truncate, :insert_new_merchants], before: Merchant, after: Merchant
      base.belongs_to_migration :big_bang, actions: [:insert_new_merchants], before: Merchant, after: Merchant
      base.belongs_to_migration :daily, actions: [:insert_new_merchants], before: Merchant, after: Merchant
    end
  end
end
