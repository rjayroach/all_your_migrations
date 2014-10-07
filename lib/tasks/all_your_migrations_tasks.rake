
def to_boolean(str, default = false)
  str.nil? ? default : str.eql?('true')
end

namespace :aym do
  task :initialize => [:environment] do
    @debug = to_boolean(ENV['debug'], false)
    @dry_run = to_boolean(ENV['dry_run'], false)
    @reset = to_boolean(ENV['reset'], false)
    @migration = ENV['migration']
  end

  task :execute => [:initialize] do
    # todo don't use mod; just check all loaded classes
    mod = Legacy
    # todo shoudl be a class of AYM::Migratable
    ar_classes = mod.constants.select {|c| mod.const_get(c).is_a? Class}.select {|c| mod.const_get(c) < ActiveRecord::Base}
    tables = ar_classes.collect {|c| mod.const_get(c).table_name }
    # todo implement before and after in the Object and leverage it here
    tables.each do |table|
      eval(table).migrations(@migration).each {|migration| migration.execute! }
    end
  end
end

