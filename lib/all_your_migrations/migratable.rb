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
      def current_time(field)
        "'#{Time.now.in_time_zone('UTC').to_s(:db)}' as #{field}"
      end

      def migrate_option_key=(key)
        raise(ArgumentError, ":key must be a valid column") unless self.columns_hash.keys.include? key.to_s
        migration_options.key = key.to_sym
      end
      
      def migrate_option_legacy_tables=(legacy_tables)
        raise(ArgumentError, ":legacy_tables must be an Array") unless legacy_tables.class.eql? Array
        migration_options.legacy_tables = legacy_tables
      end

      def migration_options
        @migration_options ||= MigrationOptions.new
      end

      def run_code(proc_object)
        new_action(nil, :proc).proc_object(proc_object)
      end

      def run_sql
        new_action(nil, :sql) #.sql(sql)
      end

      def insert_into(model)
        new_action(model, :insert)
      end

      def update_into(model)
        new_action(model, :update)
      end

      def truncate(model = self)
        new_action(model, :truncate)
      end

      def new_action(model, type)
        Action.new(model: model, type: type)
      end

      def belongs_to_migration(name, actions: [], before: nil, after: nil)
        raise(ArgumentError, ":name must be unique") unless migrations(name).empty? # only one migration name per model
        migrations.append Migration.new(self, name: name, actions: [actions].flatten, before: before, after: after)
      end

      def migrations(query_type = :all)
        @migrations ||= []
        query_type.eql?(:all) ? @migrations : @migrations.select {|m| m.name.eql? query_type}
      end

      def migrated
        self.where("#{migration_options.key.to_s} is not null").order(migration_options.key)
      end

      def last_migrated_id
        return nil if migration_options.key.nil?
        migrated.last.try(migration_options.key) || 0
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

