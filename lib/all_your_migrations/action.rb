module AllYourMigrations
  class Action
    attr_reader :model

    def initialize(model: nil, type: nil)
      #method(__method__).parameters.map { |arg| send eval("@#{arg[1]}").to_sym, eval(arg[1].to_s) }
      @model = model
      @type = type
      @key = model.migration_options.key
      @legacy_tables = model.migration_options.legacy_tables # work-around, should be just legacy_tables
      @values = []
      @from = nil
      @where = nil
      @set = []
      @sql = nil
      #self.name = caller_locations(2,1)[0].label.to_sym
      self
    end

    def values(*columns)
      @values = columns
      self
    end

    def from(from)
      @from = from 
      self
    end

    def where(where)
      @where = where
      self
    end

    def set(set)
      @set.append set
      self
    end

    def key(key)
      @key = key
      self
    end

    def legacy_tables(tables) # todo throw argument error if not tables.class < Array
      @legacy_tables = tables
      self
    end

    def sql(sql)
      @sql = sql
      self
    end

    def execute
      @sql || build_sql
    end

    def execute!
      ActiveRecord::Base.connection.execute(execute)
    end


    private

    def build_sql
      return sql_base_string if @legacy_tables.nil? or @legacy_tables.empty?
      # todo table,database should be gotten from code which sits in the same class as the code that generates the array
      @legacy_tables.inject(sql_base_string) do |query_string, element|
        table, database = element
        query_string.gsub("`#{table}`", "#{database}.#{table}")
      end
    end

    def sql_base_string
      send(@type)
    end

    def insert
      "insert into #{@model.table_name} (#{@values.join(',')}) #{@from.to_sql}"
    end

    def update
      "update #{from_string}#{set_string}#{where_string}"
    end

    def truncate
      "truncate table #{@model.table_name}"
    end

    def from_string
      @from.to_sql[@from.to_sql.index(' FROM ') + 6 .. -1]
    end

    def set_string
      @set.empty? ? '' : " set #{@set.join(', ')}"
    end

    def where_string
      (@where.nil? or @where.blank?) ? '' : " where #{@where}"
    end

  end
end
