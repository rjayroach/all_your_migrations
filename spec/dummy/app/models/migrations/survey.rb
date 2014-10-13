module Migrations
  module Survey
    extend ActiveSupport::Concern
=begin
    include AllYourMigrations::Migratable

    module ClassMethods

      # Insert new records created since last import
      def insert_new_surveys
        insert_into(self).sql('test')
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.belongs_to :legacy, class_name: 'Legacy::Survey'
      base.last_migrated_id_column = 'legacy_id'
      base.on_migrate :insert_new_surveys
    end
=end
  end
end
