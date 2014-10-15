
def to_boolean(str, default = false)
  str.nil? ? default : str.eql?('true')
end

namespace :aym do
  task :initialize => [:environment] do
    @debug = to_boolean(ENV['debug'], false)
    @dry_run = to_boolean(ENV['dry_run'], false)
    #@reset = to_boolean(ENV['reset'], false)
    @migration = ENV['migration'].try(:to_sym)
  end

  desc 'Run a legacy AYM migration'
  task :run => [:initialize] do
    next unless @migration
    Merchant.first # todo this needs to be loaded or next line returns []; this is a problem
    ActiveRecord::Base.descendants.select {|model| model.respond_to? :migrations}.each do |model|
      # todo implement before and after in the Object and leverage it here
      model.migrations(@migration).each do |migration|
        STDOUT.puts "\n-- #{Time.now} begin #{model.table_name} #{migration.name}" if @debug
        actions_sql = @dry_run ? migration.to_sql : migration.run!
        actions_sql.each {|sql| STDOUT.puts "#{sql}\n\n" } if @debug
        STDOUT.puts "-- #{Time.now} finished\n\n" if @debug
      end
    end
  end
end

