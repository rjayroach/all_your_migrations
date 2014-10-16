module AllYourMigrations
  class Action
    attr_reader :model

    def initialize(model: nil, type: nil)
      #method(__method__).parameters.map { |arg| send eval("@#{arg[1]}").to_sym, eval(arg[1].to_s) }
      #self.name = caller_locations(2,1)[0].label.to_sym
      @model = model
      @type = type
      @values = []
      @from = nil
      @where = nil
      @set = []
      @sql = nil
      @proc_object = nil
      @migration_options = {}
      self
    end

    def migration_options(options = nil)
      raise(ArgumentError, ":options must be a Hash") if options and not options.class.eql? Hash
      @migration_options = options if options
      if @model
        @model.migration_options.merge(@migration_options || {})
      else
        @migration_options
      end
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

    def primary_key(key)
      raise(ArgumentError, ":primary_key must be set on a model") unless @model
      raise(ArgumentError, "column not found #{key} on #{@model.table_name} :primary_key must be a valid column") unless @model.columns_hash.keys.include? key.to_s
      @migration_options[:primary_key] = key
      self
    end

    def legacy_tables(tables)
      raise(ArgumentError, ":tables must be an Array") if tables and not tables.class.eql? Array
      @migration_options[:legacy_tables] = tables
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
      raise(ArgumentError, ":to_sql requires a model to be set") unless @model
      # todo would be nicer to have the last_legacy_id and other functions actually delegate to the action, rather than overwriting the model
      em = @model.migration_options
      @model.migration_options(migration_options) # swap options from Action into model to generate SQL
      return_sql = @sql || build_sql
      @model.migration_options(em)
      return_sql
    end

    def execute!
      # todo make sure call has model options set
      @proc_object.call and return if @type.eql? :proc
      @model.last_migrated_id(0) if @model and @type.eql? :truncate
      sql_string = to_sql
      ActiveRecord::Base.connection.execute(sql_string)
      sql_string
    end


    private

    def build_sql
      return 'proc' if @type.eql? :proc
      return sql_base_string if migration_options[:legacy_tables].nil?
      migration_options[:legacy_tables].inject(sql_base_string) do |query_string, table|
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
