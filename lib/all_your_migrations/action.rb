module AllYourMigrations
  class Action
    attr_reader :model

    def initialize(model: nil, type: nil)
      #method(__method__).parameters.map { |arg| send eval("@#{arg[1]}").to_sym, eval(arg[1].to_s) }
      @model = model
      @type = type
      @key = model.migration_options.key if model
      @legacy_tables = model.migration_options.legacy_tables if model # work-around, should be just legacy_tables
      @values = []
      @from = nil
      @where = nil
      @set = []
      @sql = nil
      @proc_object = nil
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

    def legacy_tables(tables)
      raise(ArgumentError, ":tables must be an Array") unless tables.class.eql? Array
      @legacy_tables = tables
      self
    end

    def sql(sql)
      @sql = sql
      self
    end

    def proc_object(proc_object)
      @proc_object = proc_object
      self
    end

    def to_sql
      @sql || build_sql
    end

    def execute!
      @proc_object.call and return if @type.eql? :proc
      @model.last_migrated_id(0) if @model and @type.eql? :truncate
      ActiveRecord::Base.connection.execute(to_sql)
      to_sql
    end


    private

    def build_sql
      return 'proc' if @type.eql? :proc
      return sql_base_string if @legacy_tables.nil? or @legacy_tables.empty?
      @legacy_tables.inject(sql_base_string) do |query_string, table|
        query_string.gsub("`#{table.table_name}`", "#{table.database}.#{table.table_name}")
      end
    end

    def sql_base_string
      send(@type)
    end

    def insert
      "INSERT INTO #{@model.table_name} (#{@values.join(',')}) #{@from.to_sql}"
    end

    def update
      case @model.connection_config[:adapter]
      when 'mysql2'
        ns = "UPDATE #{from_string}"
        ns.insert(ns.index(' WHERE '), set_string)
      when 'sqlite3'
        # todo this doesn't work at all
        "REPLACE INTO #{@model.table_name} (rowid,name) #{@from.to_sql}"
        #replace into table2
        #(rowid,a, b, c, d, e, f, g)
        #select dest.rowid,src.a, src.b, src.c, src.d, src.e, dest.f, dest.g
        #from table1 src
        #inner join table2 dest on src.f = dest.f
      end
    end

    def truncate
      case @model.connection_config[:adapter]
      when 'mysql2'
        "TRUNCATE TABLE #{@model.table_name}"
      when 'sqlite3'
        "DELETE FROM #{@model.table_name}"
      end
    end

    def from_string
      @from.to_sql[@from.to_sql.index(' FROM ') + 6 .. -1]
    end

    def set_string
      @set.empty? ? '' : " SET #{@set.join(', ')}"
    end

    def where_string
      (@where.nil? or @where.blank?) ? '' : " WHERE #{@where}"
    end

  end
end
