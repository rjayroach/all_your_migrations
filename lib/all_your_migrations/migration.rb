module AllYourMigrations
  class Migration
    attr_accessor :name, :model, :ar_query, :ignore_legacy_tables
    attr_reader :insert_columns, :update_string, :type

    def initialize(model: nil, ar_query: nil, insert_columns: nil, update_string: nil, ignore_legacy_tables: false)
      # name is the method_name that instantiated this object
      # can be used to call the specific migration using  migrate!(name)
      self.model = model
      self.name = caller_locations(2,1)[0].label.to_sym
      self.ar_query = ar_query
      self.insert_columns = insert_columns
      self.update_string = update_string
      self.ignore_legacy_tables = ignore_legacy_tables
    end

    #m.insert_into_columns = Array of columns
    def insert_columns=(columns)
      @type = :insert unless columns.nil?
      @insert_columns = columns
    end

    #m.update_columns = String of "set a = b"
    def update_string=(string)
      @type = :update unless string.nil?
      @update_string = string
    end

    #m.type = :insert or :update (inferred from which of two above is set)
    def type=(type)
      @type = type
    end

    def to_sql
      ignore_legacy_tables ? sql_base_string : sql_gsub_legacy_database_string
    end

    def sql_base_string
      case type
      when :insert
        "insert into #{model.table_name} (#{insert_columns.join(',')}) #{ar_query.to_sql}"
      when :update
        sql_string = ar_query.to_sql
        sql_string = sql_string[sql_string.index(' FROM ') + 6 .. -1]
        "update #{sql_string} #{update_string}"
      else
        # todo if a specifc name is passed in (case otherwise) then find it by it's name and run it
      end
    end

    def sql_gsub_legacy_database_string
      query_string = sql_base_string
      model.legacy_tables.each do |table|
        query_string = query_string.gsub("`#{table}`", "#{model.legacy_database}.#{table}")
      end
      query_string
    end

    def migrate!
      ActiveRecord::Base.connection.execute(to_sql)
      self
    end
  end
end

