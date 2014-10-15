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
      Rails.logger.debug {
        if Rails.application.config.respond_to?(:all_your_migrations_legacy_namespace)
          log_string = "AYM: Set namespace to #{Rails.application.config.all_your_migrations_legacy_namespace}" +
            "\nAYM: Rails autoload_paths: #{ Rails.application.config.autoload_paths}" +
            "\nAYM: Legacy tables: #{Rails.application.config.all_your_migrations_legacy_tables}"
        else
          log_string = "AYM: all_your_migrations_legacy_tables NOT set"
        end
        log_string
      }
    end
  end
end
