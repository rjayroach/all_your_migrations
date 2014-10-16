module AllYourMigrations
  class Migration
    attr_accessor :name, :actions #, :migration_options
    attr_reader :model

    def initialize(model, name: nil, actions: [], migration_options: {})
      @model = model
      self.name = name
      self.actions = actions
      @migration_options = migration_options
    end

    def migration_options(options = nil)
      raise(ArgumentError, ":options must be a Hash") if options and not options.class.eql? Hash
      @migration_options = options if options
      model.migration_options.merge(@migration_options || {})
    end

    def action_stack
      actions.inject([]) do |stack, action|
        if model.respond_to?(action)
          stack.append action
        elsif not action.eql? self.name # prevent endless recursion
          model.migrations(action).each {|m| stack.concat m.action_stack }
        end
        stack
      end
    end

    def to_sql(invoke: :to_sql)
      action_stack.inject([]) {|acc, action| acc.append model.send(action).send(invoke)}
    end

    def run!
      model.migrate do
        to_sql(invoke: :execute!)
      end
    end

  end
end
