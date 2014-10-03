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

* Configure access to the legacy database
* Model the legacy tables (suggest creating a gem for the legacy models)
* Create an initializer for this gem (legacy_namespace, legacy_databse, legacy_tables)

* Define the migrations inside the model:

	```ruby
	class Product < ActiveRecord::Base
	  on_migrate :insert_from_legacy_products

          def insert_from_legacy_products
          end
	end
	```

* Create a rake file for the migration

* run the migrations


## Contributing

1. Fork it ( https://github.com/rjayroach/all_your_migrations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
