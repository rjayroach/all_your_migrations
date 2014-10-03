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



### Additional Steps for a Legacy Database

config/environements/development.rb:
```ruby
config.eager_load = true
```

config/application.rb:
```ruby
config.all_your_migrations.legacy_namespace = Legacy
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

```ruby
class Merchant < ActiveRecord::Base
  include AllYourMigrations::Migratable
  belongs_to :legacy, class_name: 'Legacy::Vendor'
  last_migrated_id_column = 'legacy_id'
  on_migrate :insert_new_merchants


  # Insert new records created since last import
  def insert_new_merchants
    migrate(model: self,
            ar_query: Legacy::Vendor.where('vendor_id > ?', last_migrated_id)
                                    .select(:vendor_id,
                                            :create_date,
                                            :last_updated_date,
                                            :name,
                                            'IF(`vendor`.`active` = 1, 4, 5)',
                                            :vendor_logo,
                                            "'perx_stamp.png'",
                                            :uses_amex,
                                            :amex_issuer_id),

            insert_columns: %i(legacy_id created_at updated_at name state logo stamp uses_amex amex_issuer_code)
    )
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
