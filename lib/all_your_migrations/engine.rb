module AllYourMigrations
  class Engine < ::Rails::Engine
    config.after_initialize do
      Rails.application.config.all_your_migrations_legacy_tables = 
        if Rails.application.config.respond_to? :all_your_migrations_legacy_namespace 
          mod = Rails.application.config.all_your_migrations_legacy_namespace
          ar_classes = mod.constants.select {|c| mod.const_get(c).is_a? Class}.select {|c| mod.const_get(c) < ActiveRecord::Base}
          ar_classes.collect {|c| modi = mod.const_get(c); OpenStruct.new(table_name: modi.table_name, database: modi.connection_config[:database]) }
        else
          []
        end
      #STDOUT.puts '$' * 50
      #STDOUT.puts Rails.application.config.all_your_migrations_legacy_namespace
      #STDOUT.puts Rails.application.config.autoload_paths
      #STDOUT.puts  Rails.application.config.respond_to? :all_your_migrations_legacy_namespace 
      #STDOUT.puts Rails.application.config.all_your_migrations_legacy_tables
      #STDOUT.puts '$' * 50
    end
  end
end
