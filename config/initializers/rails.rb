=begin
STDOUT.puts 'hello'
if defined?(Rails)
  mod = Legacy
  #Rails.application.railties.each { |r| r.eager_load! if r.respond_to?(:eager_load!) } if Rails.env.eql? 'development'
  ar_classes = mod.constants.select {|c| mod.const_get(c).is_a? Class}.select {|c| mod.const_get(c) < ActiveRecord::Base}
  STDOUT.puts ar_classes
  config.all_your_migrations_legacy_namespace
  tables = ar_classes.collect {|c| mod.const_get(c).table_name }
  STDOUT.puts tables
  STDOUT.puts 'done'
end
=end
