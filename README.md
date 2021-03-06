# AllYourMigrations

## About You
You are:
* Developing a shiny new Rails app that will be working with (or replacing) a legacy application
* Dealing with (avoiding, dreading, awake late at night, etc) writing migration code to convert the legacy database
* Looking for something to give you:

* straight forward query statements using A/R, but still want
* best performance you can get by running raw SQL and
* support for one off and periodic, e.g. daily, hourly, etc, migrations and
* transparent support for joins against legacy DB

Then:

All your migrations are belong to us!


## About This Gem
Documentation
include a sample rake file with big bang and daily migrations

include a database.yml file example with legacy db confif

in a separate repo:
a sample rails app with a new bd, a legacy db with crazy table names, legacy namespaced models, new models with the AYM code, rake files to migrate and seed data in the form of a sql dump. rake db:seed runs the dump back into legacy



## Installation

Add this line to your application's Gemfile:

    gem 'all_your_migrations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install all_your_migrations

## Usage

Settings
NOTE: AYM migration_options can be set at the global, model and/or migration (NOT action) levels; The more specific setting takes precedence
NOTE: primary_key and legacy_tables can be set globally; run_after only makes sense at model level and below

```ruby
{:namespaces=>[Legacy], :primary_key=>:legacy_id, :legacy_tables=>nil, :run_after=>Migrations::Merchant}

Likely to set at Application level: namespaces, primary_key (legacy_tables is set automagically from namespaces value)
Likely to be set at model level: primary_key, legacy_tables, run_after
Likely to be set at migration level: primary_key, legacy_tables, run_after
Likely to be set at action level: primary_key, legacy_tables

```


### Additional Steps for a Legacy Database

config/environements/development.rb:
```ruby
config.eager_load = true
```

config/application.rb:
```ruby
config.to_prepare do
  Rails.application.config.migration_options = {namespaces: Legacy, primary_key: :legacy_id}
end
```

#### Configure access to the legacy database
```ruby
legacy:
  <<: *default
  database: legacy_db
  username: <%= ENV["DB_USERNAME"] %>
  password: <%= ENV["DB_PASSWORD"] %>
  host: <%= ENV["DB_HOST"] %>
```

#### Model the legacy tables
We suggest creating a gem for the legacy models

```ruby
module Legacy
  class Vendor < ActiveRecord::Base
    establish_connection :legacy
    self.table_name = "vendor"
    self.primary_key = "vendor_id"
    belongs_to :city
    has_many :vendor_addresses
  end
end
```

* Create an initializer for this gem (legacy_namespace, legacy_databse, legacy_tables)

#### Define the migrations inside the model:

Assuming you have two models, Vendor and Merchant. Vendor is the legacy model in the legacy database

NextThing.migrations(:big_bang).execute!

```ruby
class Merchant < ActiveRecord::Base
  include AllYourMigrations::Migratable
  belongs_to :legacy, class_name: 'Legacy::Vendor'
  migration_option_key: :legacy_id
  belongs_to_migration :big_bang, actions: [:insert_new_merchants]

def insert_new_merchant
  insert_into(self).values(columns).from(A/R query).key_on(:legacy_id).with_legacy_table_map(nil)
  # insert_into, values and from are methods on Migration
end

def update_place_code
  update_into(self).from(A/R query).set(set string).where(where string)
  # update_into, from, set and where are methods on Migration
end


  # Insert new records created since last import
  def insert_new_merchants
    insert_into(self).values(:legacy_id,
                             :created_at,
                             :updated_at,
                             :name,
                             :state,
                             :logo)
                     .from(Legacy::Vendor.where('vendor_id > ?', last_migrated_id)
                                         .select(:vendor_id,
                                                 :create_date,
                                                 :last_updated_date,
                                                 :name,
                                                 'IF(`vendor`.`active` = 1, 4, 5)',
                                                 :vendor_logo)
                     .link_by(:legacy_id)
  end
end
```


### Migrating

#### Sample Migration Rakefile
To run from cli (for testing or to invoke from capistrano, etc) you can include tasks
The organization here is something we've refined over several migrations and works well for us


```ruby
def to_boolean(str, default = false)
  str.nil? ? default : str.eql?('true')
end


namespace :aym do
  task :migrate do
    Rake::Task['aym:migrate:merchants'].invoke
  end

  namespace :migrate do
    task :initialize => [:environment] do
      @debug = to_boolean(ENV['debug'], false)
      @dry_run = to_boolean(ENV['dry_run'], false)
      @reset = to_boolean(ENV['reset'], false)
    end

    task :merchants => [:initialize] do
      Merchant.truncate! if @reset
      Merchant.migrate!
    end
  end
end
```

#### Run the Migrations

```bash
rake aym:migrate:merchants
rake aym:migrate:merchants reset=true
```


## Contributing

1. Fork it ( https://github.com/rjayroach/all_your_migrations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
