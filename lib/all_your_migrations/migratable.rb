module AllYourMigrations
  module Migratable
    extend ActiveSupport::Concern

    # last_migrated_id, legacy_tables, truncate!, insert_into, update_into, on_migrate, migrate!
    module ClassMethods
      # NOTE: All these methods are exposed to the A/R model.
      # To keep is simple, consider renaming them so they have similar naming (easier to remember)
      def truncate!
        ActiveRecord::Base.connection.execute("truncate table #{self.table_name}")
        self
      end

      # todo change to insert_into and update_into
      def migrate(model: nil, ar_query: nil, insert_columns: nil, update_string: nil, sql: sql, ignore_legacy_tables: false)
        Migration.new(model: model, ar_query: ar_query, insert_columns: insert_columns, sql: sql,
                      update_string: update_string, ignore_legacy_tables: ignore_legacy_tables)
      end

      # change to be like on_migrate: if a param is passed then set @last_migrated_id_column to it
      # if no param is passed then return the value as this method is doing
      # then get rid of last_migrated_id_column=
      def last_migrated_id
        return nil unless self.last_migrated_id_column
        self.order(self.last_migrated_id_column).last.try(self.last_migrated_id_column.to_sym) || 0
      end

      def last_migrated_id_column=(column)
        # todo throw invalid column exception
        return nil unless self.columns_hash.keys.include? column
        @last_migrated_id_column = column
      end

      # todo make an attr_reader
      def last_migrated_id_column
        @last_migrated_id_column
      end

      def on_migrate(*migrate_methods)
        @migration_methods ||= migrate_methods
      end

      # todo make an attr_writer
      def legacy_tables=(tables)
        @legacy_tables = tables
      end

      # todo set the tables in the engine initializer and then just get it here using same technique
      # todo make that config setting an array of namespaces and iterate over all of them
      def legacy_tables
        @legacy_tables ||=
          if Rails.application.config.respond_to? :all_your_migrations_legacy_namespace 
            mod = Rails.application.config.all_your_migrations_legacy_namespace
            ar_classes = mod.constants.select {|c| mod.const_get(c).is_a? Class}.select {|c| mod.const_get(c) < ActiveRecord::Base}
            ar_classes.collect {|c| modi = mod.const_get(c); [modi.table_name, modi.connection_config[:database] ]}
          else
            []
          end
      end

      #start_at = Time.now #STDOUT.puts "---- Begin at: #{Time.now}\n#{sql_string}\n" if @debug
      #end_at = Time.now #STDOUT.puts "---- End at: #{Time.now}\n" if @debug
      #[start_at, end_at]
      def migrate!(query_type = :all)
        migrations_to_run = on_migrate #query_type.eql? :all ? on_migrate : on_migrate.select {|method| method.eql? query_type }
        migrations_to_run.each { |migration| send(migration).migrate! }
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

