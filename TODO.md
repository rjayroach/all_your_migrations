# Todo

# change syntax
```ruby
# all of the new methods take an object or a string except set and where which just take strings
# those methods that take an object just append their string to the Migration model's .sql property
def insert_new_merchant
  insert_into(self).values(columns).from(A/R query).key_on(:legacy_id).with_legacy_table_map(nil)
  # insert_into, values and from are methods on Migration
end

def update_place_code
  update_into(self).from(A/R query).set(set string).where(where string)
  # update_into, from, set and where are methods on Migration
end

def nuke_and_bang
  truncate!
  big_bang
end

def big_bang
  insert_new_merchants!  <-- these methods w/out the ! call insert_into or update_into; those methods can detect the calling funciton and
  update_place_code!           use meta programming to add the method with a ! which calls migrate! on the Migration object
                         <-- calling these methods w/out the ! will just return the SQL
end

def daily
  update_place_code!
end

on_migration :big_bang, execute: [:insert_new_merchants!, :update_place_code!]
on_migration :nuke_and_bang, execute: [:truncate!, :big_bang!] (,before: Merchant, :all || after: Merchant) # if :all then it is first
^-- this uses meta programming to create the method nuke_and_bang on the model which returns the execute list. it aslo create nuke_and_bang! which runs the migration
OR it doesn't create these methods, it just looks them up in a hash or array



rake migrate type=big_bang
So then we have a standard rake file which:
1. calls each model's migrations_for( type: :big_bang || method: :method_name )
2. builds an array in order so it gets done
3. Global.migrate! <-- calls through the array in order of priority and does it

OR

Merchant.big_bang!
NextThing.migrate!(:big_bang)
....


when looping over method array, if method != all then check the name matches
```

# only require activesupport/concerns

## capture all options in one method name:
so change 
```ruby
last_migrated_id_column = 'legacy_id'
```
to
```ruby
migrate_with: last_migrated_id_column: 'legacy_id', ignore_legacy_tables: true
```

## create a method `since_last_migration`
this method automatically adds the corrext where clause and must be executed each time (e.g. a Proc)

## config initializer for migrations:
if set legacy_database and table names then apply them to all migrations automatically. can be overriden by the table with a += %w(table)
get the basic code working in a manner normal for Rails

## support multiple namespaces for listng models in a specific namespace, e.g. Legacy
change to array

## when including the gem, it adds itself to AR::Base so it shows up for all models automatically

## migrate! method has ability to remove and rebuild indexes after migration has run

## create a rake task that executes the migrations
reset, dry_run, verbose, etc: whether to drop etc

big bang:
ReportSurvey.truncate! if @reset
ReportSurvey.migrate!

daily:
ReportSurvey.migrate!

## Re-work original big bang rake task on legacy for merchants and other stuff to see how well it works
       sanitize: an array of SQL strings to run to fix up a table
       this will become just another method on the model that gets run in order it was added
       implement this on one of the legacy tables, e.g. Punches

## rename the module methods that get included in the A/R model so they are easy to remember
move internal methods to after private
the also document in the readme the public methods

