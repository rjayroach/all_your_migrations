module AllYourMigrations
  class MigrationOptions
    attr_accessor :key

    def initialize(key: nil, legacy_tables: nil)
      self.key = key
      @legacy_tables = legacy_tables
    end

    def legacy_tables
      @legacy_tables ||= Rails.application.config.all_your_migrations_legacy_tables
    end
  end
end

