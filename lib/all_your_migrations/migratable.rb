module AllYourMigrations
  module Migratable
    extend ActiveSupport::Concern

    module ClassMethods
      def truncate!
        ActiveRecord::Base.connection.execute("truncate table #{self.table_name}")
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
        migrate_methods.each do |m_method|
          query_type, query, sql = send(m_method)
          add_migration_query(query_type: query_type, query: query, sql: sql)
        end
      end

      def add_migration_query(query_type:, query:, sql:)
        @migration_queries ||= []
        @migration_queries.append OpenStruct.new
        @migration_queries.last.query_type = query_type
        @migration_queries.last.query = query
        @migration_queries.last.sql = sql
      end


      def legacy_database=(database)
        @legacy_database = database
      end

      def legacy_database
        @legacy_database ||= nil
      end

      def legacy_tables=(tables)
        @legacy_tables = tables
      end

      def legacy_tables
        @legacy_tables ||= []
      end

      # todo get table names automagically: Legacy.constants.map {|c| Legacy.const_get(c).class}
      def gsub_legacy_database(query_string, database = legacy_database, tables = legacy_tables)
        tables.each do |table|
          query_string = query_string.gsub("`#{table}`", "#{database}.#{table}")
        end
        query_string
      end


      def migration_queries(query_type = :all)
        @migration_queries.inject([]) do |acc, query|
          sql_string = case query.query_type.to_s
          when 'insert'
            next acc unless [:all, :insert].include? query_type
            # todo check: query_string = query.to_sql if query.class.name.eql? 'ActiveRecord::Relation'
            "insert into #{table_name} #{query.sql} #{query.query.to_sql}"
          when 'update'
            next acc unless [:all, :update].include? query_type
            sql_update(query.query, query.sql)
          else
            # todo if a specifc name is passed in (case otherwise) then find it by it's name and run it
          end
          sql_string.nil? ? acc : acc.append(gsub_legacy_database(sql_string))
        end
      end


      def migrate(query_type = :all)
        self.migration_queries(query_type)
      end

      def migrate!(query_type = :all)
        executed_queries = []
        self.migration_queries(query_type).each do |query|
          executed_queries.append [query].merge(sql_exec(query))
        end
      end


      def sql_update(query, update_string)
        sql_string = query.to_sql
        sql_string = sql_string[sql_string.index(' FROM ') + 6 .. -1]
        "update #{sql_string} #{update_string}"
      end

      def sql_exec(sql_string)
        start_at = Time.now #STDOUT.puts "---- Begin at: #{Time.now}\n#{sql_string}\n" if @debug
        ActiveRecord::Base.connection.execute(sql_string) # unless @dry_run
        end_at = Time.now #STDOUT.puts "---- End at: #{Time.now}\n" if @debug
        [start_at, end_at]
      end

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

