module AllYourMigrations
  module Migratable
    extend ActiveSupport::Concern

    module ClassMethods
      def current_time(field_name = time_field)
        "'#{Time.now.in_time_zone('UTC').to_s(:db)}' as #{field_name}"
      end

      def migration_options(options = nil)
        raise(ArgumentError, ":options must be a Hash") if options and not options.class.eql? Hash
        @migration_options = options if options
        Rails.application.config.migration_options.merge(@migration_options || {})
      end

      def run_code(proc_object)
        new_action(nil, :proc).proc_object(proc_object)
      end

      def run_sql # NOTE This hasn't been fully tested
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

      def belongs_to_migration(name, actions: [], **migration_options)
        raise(ArgumentError, ":name must be unique") unless migrations(name).empty? # only one migration name per model
        migrations.append Migration.new(self, name: name, actions: [actions].flatten, migration_options: migration_options)
      end

      def migrations(query_type = :all)
        @migrations ||= []
        query_type.eql?(:all) ? @migrations : @migrations.select {|m| m.name.eql? query_type}
      end

      def migrated
        self.where("#{migration_options[:primary_key].to_s} is not null").order(migration_options[:primary_key])
      end

      def last_migrated_id(id = nil)
        return nil if migration_options[:primary_key].nil?
        @last_migrated_id = id if id
        @last_migrated_id || migrated.last.try(migration_options[:primary_key]) || 0
      end

      def migrate
        @last_migrated_id = last_migrated_id
        output = yield
        @last_migrated_id = nil
        output
      end

      # todo clean this up
      def find_in_column_type(column_type = 'datetime', value = '2011-10-17')
        #%w{ respondent_surveys transactions transaction_profiles workflows campaigns transaction_profiles workflow_tasks }.each do |table|
        # todo: use arel to do chain each column with an OR to return one result set
        self.columns_hash.select {|k,v| v.sql_type.eql? column_type}.each do |k,v|
          self.where("#{k} like '%#{value}%'")
        end
      end

      private
      def time_field
        @time_field ||= -1
        "t#{@time_field += 1}"
      end

      def new_action(model, type)
        Action.new(model: model, type: type)
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
