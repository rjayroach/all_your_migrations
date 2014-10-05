require 'active_support'
require 'active_record'

require_relative '../../../lib/all_your_migrations/action'
require_relative '../../../lib/all_your_migrations/migratable'
require_relative '../../../lib/all_your_migrations/migration'
require_relative '../../../lib/all_your_migrations/migration_options'
p ActiveRecord::VERSION::STRING

module AllYourMigrations
  describe Action do
    before :each do
      ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
      ActiveRecord::Base.connection.instance_eval do
        create_table(:people) { |t| t.string :name }
      end

      class Person < ActiveRecord::Base
        include Migratable
        def self.remove_people
          truncate
        end
        def self.insert_new_people
          insert_into(self).values(:name)
                           .from(Person.all
                                       .select(:name))
        end
        migrate_option_key = :legacy_id
        belongs_to_migration :daily, actions: [:insert_new_people]
      end

      @person = Person.create! name: 'Aaron'
    end

    it 'has an id' do
      expect(@person.id).to eq 1
    end

    it 'adds a migration' do
      pending 'fails'
      expect(Person.migrations.size).to eq 1
    end

    it 'migrates a new person' do
      expect(Person.count).to eq 1
      #Person.send(Person.migrations.first.actions.last).execute!
      Person.insert_new_people.execute!
      expect(Person.count).to eq 2
    end

    describe '#truncate' do
      it 'removes all records from the table' do
        expect(Person.count).to eq 1
        Person.remove_people.execute!
        expect(Person.count).to eq 0
      end
    end
  end
end





