
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
    Merchant.first # todo this is a problem
    ActiveRecord::Base.descendants.each do |model|
      next unless model.respond_to? :migrations
      # todo implement before and after in the Object and leverage it here
      model.migrations.select {|migration| migration.name.eql? @migration}.each do |migration|
        STDOUT.puts "\n---- #{model.table_name} #{migration.name} began at: #{Time.now}" if @debug
        migration.execute.each {|action| STDOUT.puts "#{action}\n\n" } if @debug
        migration.execute! unless @dry_run
        STDOUT.puts "---- Finished at: #{Time.now}\n\n" if @debug
      end
    end
  end
end

