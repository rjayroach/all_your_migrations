module AllYourMigrations
  module Migratable
    extend ActiveSupport::Concern

    # inherited settings: legacy_tables
    # chained settings: insert_into, update_into
    # action settings: on_migrate [], link_by :legacy_id (link_by used to be last_migrated_id_column), also support legacy_tables([])
    # remove ignore_legacy_tables; if the migration should ignore them just add a .legacy_tables(nil) to the insert_into / update_into chain
    # note: link_by and ignore_legacy_tables can both be set on each individual query as well
    # actions: truncate, truncate!, migrate, migrate! (the non-destructive versions return the SQL string that would have run)
    # helper actions: find_in_column_type
    # object: last_migrated, first_migrated (maybe - this would be the first object migrated in this batch)
    module ClassMethods
      # NOTE: All these methods are exposed to the A/R model.
      # To keep is simple, consider renaming them so they have similar naming (easier to remember)
      def truncate!
        ActiveRecord::Base.connection.execute("truncate table #{self.table_name}")
        self
      end

      # todo change to insert_into and update_into
      # todo then the migrate method is going to process an options hash for ignore_legacy_tables, last_migrated_id_column etc
      def migrate(model: nil, ar_query: nil, insert_columns: nil, update_string: nil, sql: sql, ignore_legacy_tables: false)
        Migration.new(model: model, ar_query: ar_query, insert_columns: insert_columns, sql: sql,
                      update_string: update_string, ignore_legacy_tables: ignore_legacy_tables)
      end

      # todo add a method last_migrated that returns the last migrated object based on order
      # todo change this method to use last_migrated and then call #migrate_key on it to get the actual value
      def last_migrated_id
        return nil unless self.last_migrated_id_column
        self.order(self.last_migrated_id_column).last.try(self.last_migrated_id_column.to_sym) || 0
      end

      def last_migrated_id_column=(column)
        # todo throw invalid column exception
        return nil unless self.columns_hash.keys.include? column
        @last_migrated_id_column = column
      end

      # todo get rid of after migrate method is changed
      def last_migrated_id_column
        @last_migrated_id_column
      end

      def on_migrate(*migrate_methods, link_to: nil, ignore_legacy_tables: nil)
        @migration_methods ||= migrate_methods
        @link_to = link_to
        @ignore_legacy_tables = ignore_legacy_tables
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
      def find_in_column_type(column_type = 'datetime', value = '2011-10-17')
        #%w{ respondent_surveys transactions transaction_profiles workflows campaigns transaction_profiles workflow_tasks }.each do |table|
        # todo: use arel to do chain each column with an OR to return one result set
        self.columns_hash.select {|k,v| v.sql_type.eql? column_type}.each do |k,v|
          self.where("#{k} like '%#{value}%'")
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

