Rails.application.routes.draw do

  mount AllYourMigrations::Engine => "/all_your_migrations"
end
