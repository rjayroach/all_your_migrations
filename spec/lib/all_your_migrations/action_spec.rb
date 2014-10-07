require 'spec_helper'
#require 'pry'

def execute_sql(action)
  action.execute.gsub(/\"/, '')
end

module AllYourMigrations
  describe Action do

    context 'insert' do
      describe '#execute' do
        it 'returns the correct SQL' do
          a = Action.new(model: Person, type: :insert)
          a.values(:name)
          a.from(Person.all.select(:name))
          expect(execute_sql(a)).to eq('INSERT INTO people (name) SELECT people.name FROM people')
        end
      end
    end

    context 'update' do
      describe '#execute' do
        before :example do
          @action = Action.new(model: Person, type: :update)
          @action.from(Vendor.joins(:person).where(person: {active: true}).select(:name)) #.set('name = "vendors"."name"')
          @action.from(Vendor.joins(:person).select(:id, :name)) #.set('name = "vendors"."name"')
        end

        it 'returns the correct SQL' do
          expect(execute_sql(@action)).to eq('UPDATE people INNER JOIN vendors ON vendors.person_id = people.id SET name = vendor.name WHERE active = true')
        end

        it 'executes the correct SQL' do
          #@action.from(Person.joins(:vendor)) #.set('name = vendor.name')
          #binding.pry
          STDOUT.puts @action.execute
          @action.execute!
          expect(@person.name).to eq 'Vendor!'
          expect(@person2.name).to eq 'Fred'
        end
      end
    end

    context 'truncate' do
      describe '#execute' do
        it 'removes all records from the table' do
          #expect { Person.remove_people.execute! }.to change{Person.count}.by(-1)
          Person.remove_people.execute!
          expect(Person.count).to eq 0
        end
      end
    end

=begin
    describe '#truncate' do
      it 'adds a migration' do
        pending 'fails'
        expect(Person.migrations.size).to eq 1
      end

      it 'migrates a new person' do
        pending 'move to migratable_spec.rb'
        expect(Person.count).to eq 1
        Person.insert_new_people.execute!
        expect(Person.count).to eq 2
      end
    end
=end
  end
end





