module AllYourMigrations
  class Migration
    attr_accessor :name, :actions, :before, :after

    def initialize(model, name: nil, actions: [], before: nil, after: nil)
      @model = model
      self.name = name
      self.actions = actions
      self.before = before
      self.after = after
    end

    def action_stack
      actions.inject([]) do |stack, action|
        if @model.respond_to?(action)
          stack.append action
        elsif not action.eql? self.name # prevent endless recursion
          @model.migrations(action).each {|m| stack.concat m.action_stack }
        end
        stack
      end
    end

    def to_sql(invoke: :to_sql)
      action_stack.each {|action| @model.send(action).send(invoke)}
    end

    def run!
      to_sql(invoke: :execute!)
    end

  end
end

