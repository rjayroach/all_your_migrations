module AllYourMigrations
  class Migration
    attr_accessor :model, :ar_query, :name, :type, :sql, :ignore_legacy_tables
    attr_reader :insert_columns, :update_string
      

    def initialize(model: nil, ar_query: nil, insert_columns: nil, update_string: nil, sql: nil, ignore_legacy_tables: false)
      # name is the method_name that instantiated this object
      # can be used to call the specific migration using  migrate!(name)
      self.model = model
      self.ar_query = ar_query
      self.insert_columns = insert_columns
      self.update_string = update_string
      self.ignore_legacy_tables = ignore_legacy_tables
      self.sql = sql
      self.name = caller_locations(2,1)[0].label.to_sym
    end

    # Array of columns that will be populated from the ar_query
    def insert_columns=(columns)
      self.type = :insert unless columns.nil?
      @insert_columns = columns
    end

    #m.update_columns = String of "set a = b"
    def update_string=(string)
      self.type = :update unless string.nil?
      @update_string = string
    end

    def to_sql
      self.sql || build_sql
    end

    def migrate!
      ActiveRecord::Base.connection.execute(to_sql)
      self
    end


    private

    def build_sql
      return sql_base_string if ignore_legacy_tables
      model.legacy_tables.inject(sql_base_string) do |query_string, element|
        table, database = element
        query_string.gsub("`#{table}`", "#{database}.#{table}")
      end
    end

    # todo handle types other than 'insert' and 'update'
    def sql_base_string
      send(type)
    end

    def insert
      "insert into #{model.table_name} (#{insert_columns.join(',')}) #{ar_query.to_sql}"
    end

    def update
      sql_string = ar_query.to_sql
      sql_string = sql_string[sql_string.index(' FROM ') + 6 .. -1]
      "update #{sql_string} #{update_string}"
    end

  end
end

