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

    def execute(invoke: :execute)
      actions.inject([]) do |result, action|
        if @model.respond_to?(action)
          result.append @model.send(action).send(invoke)
        elsif not action.eql? self.name # prevent endless recursion
          @model.migrations(action).each {|m| m.execute(invoke: invoke)}
        end
      end
    end

    def execute!
      execute(invoke: :execute!)
    end

  end
end

