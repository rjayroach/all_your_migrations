# Todo

## Must
### process model migrations in order of before/after
1. builds an array in order so it gets done
2. Global.migrate! <-- calls through the array in order of priority and does it

### Figure out problem loading models in the default namespace for processing migrations
See rake task for this
Also about legacy models not completely loaded (see require_relative in legacy/vendor.rb model)

### test that change the key is working per action
Is this really necessary per _action_?
may be appropriate per model. There was a requirement for this somewhere in migrations


## Should

### migrate! method has ability to remove and rebuild indexes after migration has run

### config initializer for migrations: (FIX)
if set legacy_database and table names then apply them to all migrations automatically. can be overriden by the table with a += %w(table)
get the basic code working in a manner normal for Rails

### Have model.migrations(:name) return a single migration rather than an array


## Could
### support multiple namespaces for listng models in a specific namespace, e.g. Legacy
change to array

### only require activesupport/concerns


### Re-work original big bang rake task on legacy for merchants and other stuff to see how well it works
       sanitize: an array of SQL strings to run to fix up a table
       this will become just another method on the model that gets run in order it was added
       implement this on one of the legacy tables, e.g. Punches

