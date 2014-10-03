# Todo

# only require activesupport/concerns

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

