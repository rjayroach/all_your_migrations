module AllYourMigrations
  class Engine < ::Rails::Engine
    config.after_initialize do
      Rails.application.config.migration_options = {} unless Rails.application.config.respond_to? :migration_options
      options = Rails.application.config.migration_options
      options[:namespaces] ||= []
      options[:namespaces] = [options[:namespaces]].flatten
      options[:legacy_tables] ||=
        options[:namespaces].inject([]) do |acc, mod|
          ar_classes = mod.constants.select {|c| mod.const_get(c).is_a? Class}.select {|c| mod.const_get(c) < ActiveRecord::Base}
          acc.append ar_classes.collect {|c| modi = mod.const_get(c); OpenStruct.new(table_name: modi.table_name, database: modi.connection_config[:database]) }
        end.flatten
      Rails.logger.debug do
        "AYM: Set namespaces to #{options[:namespaces]}" +
        "\nAYM: Rails autoload_paths: #{Rails.application.config.autoload_paths}" +
        "\nAYM: Legacy tables: #{options[:legacy_tables]}"
      end
    end
  end
end
