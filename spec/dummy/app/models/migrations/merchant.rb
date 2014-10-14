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

      def proper_case_names
        run_code(
          # todo last_migrated_id needs to be stored per migration so it is stable between actions
          #Proc.new {where('legacy_id > ?', last_migrated_id).each {|m| m.update_attributes(name: m.name.titleize)}}
          Proc.new {all.each {|m| m.update_attributes(name: m.name.titleize)}}
        )
      end

      def truncate_client_merchants
        truncate(ClientMerchant)
      end

      def insert_client_merchants
        insert_into(ClientMerchant).values(:merchant_id, :client_id, :created_at, :updated_at)
                                   .from(self.joins(:legacy)
                                             .select('merchants.id',
                                                     "case `vendor`.city_id when 6 then 2 else 1 end",
                                                     current_time('t1'),
                                                     current_time('t2')))
      end

      def truncate_regional_merchants
        truncate(RegionalMerchant)
      end

      def insert_regional_merchants
        insert_into(RegionalMerchant).values(:merchant_id, :region_id, :created_at, :updated_at)
                                     .from(self.joins(:legacy)
                                               .select('merchants.id',
                                                       "case `vendor`.city_id when 1 then 1 when 6 then 3 when 4 then 2 when 3 then 5 when 2 then 4 else 1 end",
                                                       current_time('t1'),
                                                       current_time('t2')))
      end


      def truncate_locations
        truncate(Location)
      end

      def insert_new_locations
        insert_into(Location).values(:legacy_id,
                                     :merchant_id,
                                     :state,
                                     :phone,
                                     :postal_code,
                                     :code,
                                     :latitude,
                                     :longitude,
                                     :region_id,
                                     :created_at,
                                     :updated_at)
                             .from(Legacy::VendorAddress.joins('INNER JOIN merchants ON merchants.legacy_id = `vendor_address`.vendor_id')
                                                        .joins('INNER JOIN regional_merchants ON regional_merchants.merchant_id = merchants.id')
                                                        .where(addr_type: 1)
                             .select(
            '`vendor_address`.vendor_addr_id',
            'merchants.id',
            "IF(`vendor_address`.active = '1', 4, 1)",
            '`vendor_address`.phone',
            '`vendor_address`.zipcode',
            'vendor_code',
            "IF(`vendor_address`.latitude is not null && `vendor_address`.latitude != '' && `vendor_address`.latitude != 'Singapore', CAST(`vendor_address`.latitude AS DECIMAL(10,7)), NULL)",
            "IF(`vendor_address`.longitude is not null && `vendor_address`.longitude != '' && `vendor_address`.longitude != 'Singapore', CAST(`vendor_address`.longitude AS DECIMAL(10,7)), NULL)",
            'regional_merchants.region_id',
            '`vendor_address`.last_updated_date as t1',
            '`vendor_address`.last_updated_date as t2'))

=begin
              #from #{@legacy_database}.#{legacy_table} #{legacy_table}
              #  join #{@database}.#{link_table.pluralize} #{link_table}
              #    on #{link_table}.legacy_id = #{legacy_table}.vendor_id
              #  join #{@database}.regional_merchants
              #    on #{link_table}.id = #{@database}.regional_merchants.merchant_id
              #where addr_type = 1

        sql_string = "
            select vendor_address.vendor_addr_id, merchant.id, IF(vendor_address.active = '1', 4, 1),
              #{legacy_table}.phone, #{legacy_table}.zipcode, vendor_code,
              IF(#{legacy_table}.latitude is not null && #{legacy_table}.latitude != '' && #{legacy_table}.latitude != 'Singapore', CAST(#{legacy_table}.latitude AS DECIMAL(10,7)), NULL),
              IF(#{legacy_table}.longitude is not null && #{legacy_table}.longitude != '' && #{legacy_table}.longitude != 'Singapore', CAST(#{legacy_table}.longitude AS DECIMAL(10,7)), NULL),
              #{@database}.regional_merchants.region_id,
              #{legacy_table}.last_updated_date, #{legacy_table}.last_updated_date
        "
=end
      end

      def xyz
        update_into(self).from(Legacy::Vendor.all)
                         .where('j is true')
                         .set('a = b')
                         .set('c = d')
                         #.legacy_tables(self.legacy_tables)
      end
=begin
      desc "Migrate vendor addresses to merchant locations"
      task :vendor_addresses => [:initialize, :vendor] do
        table = "location"
        legacy_table = "vendor_address"
        legacy_table_primary_key = "vendor_addr_id"
        link_table = "merchant"
        STDOUT.puts "#{Time.now} - Migrating from #{@legacy_database}.#{legacy_table} to #{@database}.#{table.pluralize};"
        ActiveRecord::Base.connection.execute("delete from #{@database}.#{table.pluralize};") if @reset

        sql_string = "
          insert into #{@database}.#{table.pluralize}
            (legacy_id, merchant_id, state,
              phone, postal_code, code,
              latitude,
              longitude,
              region_id,
              created_at, updated_at
            )
            select vendor_address.vendor_addr_id, merchant.id, IF(vendor_address.active = '1', 4, 1),
              #{legacy_table}.phone, #{legacy_table}.zipcode, vendor_code,
              IF(#{legacy_table}.latitude is not null && #{legacy_table}.latitude != '' && #{legacy_table}.latitude != 'Singapore', CAST(#{legacy_table}.latitude AS DECIMAL(10,7)), NULL),
              IF(#{legacy_table}.longitude is not null && #{legacy_table}.longitude != '' && #{legacy_table}.longitude != 'Singapore', CAST(#{legacy_table}.longitude AS DECIMAL(10,7)), NULL),
              #{@database}.regional_merchants.region_id,
              #{legacy_table}.last_updated_date, #{legacy_table}.last_updated_date
              from #{@legacy_database}.#{legacy_table} #{legacy_table}
                join #{@database}.#{link_table.pluralize} #{link_table}
                  on #{link_table}.legacy_id = #{legacy_table}.vendor_id
                join #{@database}.regional_merchants
                  on #{link_table}.id = #{@database}.regional_merchants.merchant_id
              where addr_type = 1
        "
        STDOUT.puts sql_string if @debug
        ActiveRecord::Base.connection.execute(sql_string)
=end

    end

    def self.included(base)
      base.extend(ClassMethods)
      base.belongs_to :legacy, class_name: 'Legacy::Vendor'
      base.migrate_option_key = :legacy_id
      #base.migrate_option_legacy_tables = nil
      base.belongs_to_migration :nuke_and_bang, before: Merchant, after: Merchant,
        actions: [:truncate, :truncate_client_merchants, :truncate_regional_merchants, :big_bang]
      base.belongs_to_migration :big_bang, before: Merchant, after: Merchant,
        actions: [:insert_new_merchants, :proper_case_names, :insert_client_merchants, :insert_regional_merchants]
      base.belongs_to_migration :daily, before: Merchant, after: Merchant,
        actions: [:insert_new_merchants]
    end
  end
end
