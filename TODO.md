# Todo

## Must
### process model migrations in order of before/after
1. builds an array in order so it gets done
2. Global.migrate! <-- calls through the array in order of priority and does it

### Make sure action migration_options are set on model before a proc and @sql are run
Or just get migratable methods last_legacy_id and 
Also notice that settings are inherited app->model->migration->action; Right now it is model->action
When an action is being run inside the context of a migration it should inherit from the migration, not the model

### Figure out problem loading models in the default namespace for processing migrations
See rake task for this
Also about legacy models not completely loaded (see require_relative in legacy/vendor.rb model)
also see spec/dummy/config/application.rb

## Should

### move any @instance references into getters and don't pollute the code by accessing @vars everywhere

### migrate! method has ability to remove and rebuild indexes after migration has run
Pull this out of the existing rake file, but it needs to be dynamic in that it reads the index files, removes and rebuilds them auto-magically
It should also be able to preserve certain indexes as necessary
Nice to have is to be able to build tempoarary indexes for the migration itself (to increase performance of migration)


### Have model.migrations(:name) return a single migration rather than an array


## Could

### only require activesupport/concerns


### Re-work original big bang rake task on legacy for merchants and other stuff to see how well it works
       sanitize: an array of SQL strings to run to fix up a table
       this will become just another method on the model that gets run in order it was added
       implement this on one of the legacy tables, e.g. Punches

