# Todo

 Legacy Migrations
  1. Create an Sql Object that:
     Properties:
       table: An A/R model (which is the target of the insert or update).
       query: Query to run (converted to query_string upon executing methods)
       query_string: a manual string that can be set
       reset, dry_run, verbose, etc: whether to drop etc
       last_legacy_column_name: as it says
       sanitize: an array of SQL strings to run to fix up a table

     Methods:
       insert: runs SQL insert
       update: runs SQL update
       index: It has a drop/recreate index methods to wrap around insert/update operations
       columns: it has the Jon code to identify column types with specific data. (runs SQL not A/R where due ot A/R failures
  2. Ideas:
      Module Migration
      Migration::Base inherits from ActiveRecord::Base (this is a wrapper around any A/R model, current or legacy)
      Migration::Query is an update, insert or manual query that can be attached to a Migration
      Migration::Base has a hash that is a collection of Migration::Query objects that can be run against the Base model
      Migration.sanitize runs those querys in the hash that are flagged as sanitizing queries
  3. Examples:
      class Punches inherits from Migration::Base
        def query_1 # sanitize
          ...
        end
        def sanitize
          query_1
        end
        def insert
        end
      end


## rename gem
name to all_your_migration
module AllYourMigration or AYM::

## convert method returns from an array to the class in AYM::Migration
def insert_new_blah
m = AYM::Migration.new
m.name is the method_name (this is used to call a migrate!(name) in the rake file
m.ar_query = the query
m.insert_into_columns = Array of columns
m.update_columns = String of "set a = b"
m.type = :insert or :update (inferred from which of two above is set)
return m

the Migration class also has settings for legacy_database etc that it sets from the Model class that is including it
if these properties are set in the model's migration method then ignore globals


## be able to include AYM in a model and it includes both the Migratable module and the Migration class

## add flag in migration class
ignore_legacy which be default is false

change report method to insert_new_surveys

## create a method `since_last_migration`
this method automatically adds the corrext where clause

## create a rake task that executes the migrations

7. config initializer for migrations:
if set legacy_database and table names then apply them to all migrations automatically. can be overriden by the table with a += %w(table)

8. when including the gem, what it does us adds itself to AR::Base so it shows up for all models automatically. the only methods it adds are the ones a user would set on the model itself:

on_migrate
migrate and migrate!
last_migrated_key

9. write rake task

big bang:
ReportSurvey.truncate! if @reset
ReportSurvey.migrate!

daily:
ReportSurvey.migrate!

10. migrate! method has ability to remove and rebuild indexes after migration has run

11. find a way to list all models in a specific namespace, e.g. Legacy
this by default becomes the list of tables if it is specified

