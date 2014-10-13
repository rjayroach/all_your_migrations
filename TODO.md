# Todo

# change syntax
```ruby
rake migrate type=big_bang
So then we have a standard rake file which:
1. calls each model's migrations_for( type: :big_bang || method: :method_name )
2. builds an array in order so it gets done
3. Global.migrate! <-- calls through the array in order of priority and does it
```

# only require activesupport/concerns

## config initializer for migrations: (FIX)
if set legacy_database and table names then apply them to all migrations automatically. can be overriden by the table with a += %w(table)
get the basic code working in a manner normal for Rails

## support multiple namespaces for listng models in a specific namespace, e.g. Legacy
change to array

## when including the gem, it adds itself to AR::Base so it shows up for all models automatically

## migrate! method has ability to remove and rebuild indexes after migration has run


## Re-work original big bang rake task on legacy for merchants and other stuff to see how well it works
       sanitize: an array of SQL strings to run to fix up a table
       this will become just another method on the model that gets run in order it was added
       implement this on one of the legacy tables, e.g. Punches

