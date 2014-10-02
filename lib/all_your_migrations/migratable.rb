module AllYourMigrations
  module Migratable
    extend ActiveSupport::Concern

    module ClassMethods
      # NOTE: All these methods are exposed to the A/R model.
      # To keep is simple, consider renaming them so they have similar naming (easier to remember)
      def truncate!
        ActiveRecord::Base.connection.execute("truncate table #{self.table_name}")
        self
      end

      def last_migrated_id
        return nil unless self.last_migrated_id_column
        self.order(self.last_migrated_id_column).last.try(self.last_migrated_id_column.to_sym) || 0
      end

      def last_migrated_id_column=(column)
        return nil unless self.columns_hash.keys.include? column
        @last_migrated_id_column = column
      end

      def last_migrated_id_column
        @last_migrated_id_column
      end

      def on_migrate(*migrate_methods)
        migrate_methods.each { |m_method| add_migration send(m_method) }
      end

      def add_migration(migration)
        @migration_queries ||= []
        @migration_queries.append migration
      end

      # todo support query_type
      def migrations(query_type = :all)
        @migration_queries
      end

      def legacy_database=(database)
        @legacy_database = database
      end

      def legacy_database
        @legacy_database ||= nil
      end

      # todo get table names automagically: Legacy.constants.map {|c| Legacy.const_get(c).class}
      def legacy_tables=(tables)
        @legacy_tables = tables
      end

      def legacy_tables
        @legacy_tables ||= []
      end

      #start_at = Time.now #STDOUT.puts "---- Begin at: #{Time.now}\n#{sql_string}\n" if @debug
      #end_at = Time.now #STDOUT.puts "---- End at: #{Time.now}\n" if @debug
      #[start_at, end_at]
      def migrate!(query_type = :all)
        self.migrations(query_type).each do |migration|
          migration.migrate!
        end
        self
      end


      # todo clean this up
      def where_column_type(column_type = 'datetime', value = '2011-10-17')
        #%w{ respondent_surveys transactions transaction_profiles workflows campaigns transaction_profiles workflow_tasks }.each do |table|
        self.columns_hash.select {|k,v| v.sql_type.eql? column_type}.each do |k,v|
          result = self.where("#{k} like '%#{value}%'")
          p result.first
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

